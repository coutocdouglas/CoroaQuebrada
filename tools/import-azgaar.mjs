import fs from 'node:fs';
import {pathToFileURL} from 'node:url';

const fail = message => { throw new Error(message); };
const list = (value, name) => Array.isArray(value) ? value : fail(`Lista ausente: ${name}`);
const point = p => Array.isArray(p) && p.length >= 2 && p.slice(0,2).every(Number.isFinite);
const active = rows => rows.filter(x => x && !x.removed);

// Adapter for the official Full JSON export, not the .map save format.
export function importWorld(source, catalog) {
  const pack = source.pack;
  if (!pack || !Array.isArray(pack.cells) || !Array.isArray(pack.vertices))
    fail('Exporte JSON Full no Azgaar; Minimal, GridCells e .map não possuem este contrato.');
  if (!source.info || !Number.isFinite(source.info.width) || source.info.width <= 0 ||
      !Number.isFinite(source.info.height) || source.info.height <= 0) fail('Dimensões inválidas.');
  if (catalog.regions.length !== 12 || new Set(catalog.regions.map(r=>r.id)).size !== 12)
    fail('O catálogo deve conter 12 regiões únicas.');
  const provinces = active(list(pack.provinces, 'provinces'));
  const selected = provinces.filter(p => p.state === catalog.source_state_id);
  const byName = new Map(catalog.regions.map(r => [r.name, r]));
  if (selected.length !== 12 || new Set(selected.map(p=>p.name)).size !== 12 || selected.some(p=>!byName.has(p.name)))
    fail('O estado selecionado deve ter exatamente as 12 províncias nomeadas no catálogo.');
  const regionByProvince = new Map(selected.map(p=>[p.i,byName.get(p.name).id]));
  const vertices = new Map(pack.vertices.map(v=>[v.i,v.p]));
  if (vertices.size !== pack.vertices.length) fail('Vértices duplicados.');
  const allCells = new Map(pack.cells.map(c=>[c.i,c]));
  if (allCells.size !== pack.cells.length) fail('Células duplicadas.');
  const cells = pack.cells.filter(c=>c.state===catalog.source_state_id && c.h>=20).map(c=>{
    const region = regionByProvince.get(c.province);
    if (!region) fail(`Célula terrestre ${c.i} sem região.`);
    const polygon=list(c.v,'cell.v').map(v=>vertices.get(v));
    if (polygon.length<3 || !polygon.every(point)) fail(`Polígono inválido: ${c.i}`);
    const neighbors=list(c.c,'cell.c');
    if (neighbors.some(id=>!allCells.has(id))) fail(`Vizinho inexistente: ${c.i}`);
    if (!Number.isFinite(c.pop) || c.pop<0) fail(`População inválida: ${c.i}`);
    return {id:c.i,region,polygon:polygon.map(p=>p.slice(0,2)),neighbors,
      elevation:c.h,biome:c.biome,population_raw:c.pop,culture:c.culture,religion:c.religion};
  });
  const owned = new Set(cells.map(c=>c.id));
  const regions=catalog.regions.map(r=>{
    const territory=cells.filter(c=>c.region===r.id);
    if (!territory.length) fail(`Região sem terreno: ${r.name}`);
    const neighbors=new Set();
    for(const c of territory) for(const id of c.neighbors) {
      const n=allCells.get(id); const other=regionByProvince.get(n.province);
      if(n.state===catalog.source_state_id && n.h>=20 && other && other!==r.id) neighbors.add(other);
    }
    return {...r,neighbors:[...neighbors].sort(),population_raw:territory.reduce((s,c)=>s+c.population_raw,0)};
  });
  const settlements=active(list(pack.burgs,'burgs')).filter(b=>b.i && owned.has(b.cell)).map(b=>{
    if(!point([b.x,b.y])) fail(`Povoação sem posição: ${b.i}`);
    return {id:b.i,name:b.name,region:regionByProvince.get(allCells.get(b.cell).province),
      cell:b.cell,position:[b.x,b.y],population_raw:b.population,port:Boolean(b.port),
      capital:Boolean(b.capital),citadel:Boolean(b.citadel),walls:Boolean(b.walls)};
  });
  const routes=active(list(pack.routes,'routes')).filter(r=>list(r.points,'route.points').some(p=>owned.has(p[2]))).map(r=>{
    if(r.points.length<2 || !r.points.every(point)) fail(`Rota inválida: ${r.i}`);
    return {id:r.i,group:r.group,points:r.points.map(p=>p.slice(0,3)),status:'geography_only'};
  });
  return {schema:1,kind:'world_geography',source:{tool:'Azgaar',info:source.info,settings:source.settings,
    state_id:catalog.source_state_id},regions,cells,settlements,routes,
    rivers:pack.rivers??[],cultures:pack.cultures??[],religions:pack.religions??[],
    warnings:['População bruta do gerador: aplicar escala antes de usar na economia.',
      'Rotas podem cruzar terras estrangeiras. Não representam transações ativas.',
      'Domínios, governantes, estoques e lealdades ainda devem ser definidos no jogo.']};
}
if(process.argv[1] && import.meta.url===pathToFileURL(process.argv[1]).href) {
  try {
    const [, , input, configuration, output]=process.argv;
    if(!input || !configuration || !output) fail('Uso: node tools/import-azgaar.mjs Full.json catalog.json output.json');
    if(fs.existsSync(output)) fail('Destino já existe; escolha outro nome para preservar a versão anterior.');
    const result=importWorld(JSON.parse(fs.readFileSync(input,'utf8').replace(/^\uFEFF/,'')),
      JSON.parse(fs.readFileSync(configuration,'utf8').replace(/^\uFEFF/,'')));
    fs.writeFileSync(output,JSON.stringify(result,null,2));
    console.log(`${result.regions.length} regiões, ${result.cells.length} células, ${result.settlements.length} povoações, ${result.routes.length} rotas.`);
  } catch(error) { console.error(error.message); process.exitCode=1; }
}
