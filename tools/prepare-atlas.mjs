import fs from 'node:fs';
import {createHash} from 'node:crypto';
import {importWorld} from './import-azgaar.mjs';
const raw=fs.readFileSync('data/world/source/azgaar-full.json','utf8');
const source=JSON.parse(raw),catalog=JSON.parse(fs.readFileSync('data/world/catalog.json','utf8').replace(/^\uFEFF/,''));
const world=importWorld(source,catalog),pack=source.pack;
fs.writeFileSync('data/world/kingdom.json',JSON.stringify(world));
const vertex=new Map(pack.vertices.map(v=>[v.i,v.p]));
const cellMap=new Map(pack.cells.map(c=>[c.i,c]));
const own=new Map(world.cells.map(c=>[c.id,c.region]));
const provinces=pack.provinces.filter(p=>p&&!p.removed&&p.state===catalog.source_state_id);
const regions=world.regions.map((r,index)=>{const p=provinces.find(p=>p.name===r.name);const seat=world.settlements.find(b=>b.id===p.burg);return {...r,number:index+1,color:p.color,anchor:p.pole,seat_id:p.burg,seat_name:seat?.name??'',settlements:world.settlements.filter(b=>b.region===r.id).length};});
const terrain=pack.cells.filter(c=>c.h>=20).map(c=>({id:c.i,region:own.get(c.i)??'',height:c.h,polygon:c.v.map(v=>vertex.get(v))}));
const edges=new Map();
for(const c of pack.cells){if(c.h<20)continue;for(let i=0;i<c.v.length;i++){const a=c.v[i],b=c.v[(i+1)%c.v.length],key=[a,b].sort((x,y)=>x-y).join(':');if(!edges.has(key))edges.set(key,[]);edges.get(key).push({cell:c.i,a,b});}}
const borders=[];
for(const es of edges.values()){const a=es[0],r1=own.get(a.cell)??'',r2=es.length>1?(own.get(es[1].cell)??''):'';if(es.length===1||r1!==r2)borders.push({points:[vertex.get(a.a),vertex.get(a.b)],regions:[r1,r2],coast:es.length===1});}
const rivers=pack.rivers.map(r=>({id:r.i,points:r.cells.map(i=>cellMap.get(i)?.p).filter(Boolean)})).filter(r=>r.points.length>1);
const routes=world.routes.map(r=>({...r,regions:[...new Set(r.points.map(p=>own.get(p[2])).filter(Boolean))],length_km:Math.round(r.points.slice(1).reduce((s,p,i)=>s+Math.hypot(p[0]-r.points[i][0],p[1]-r.points[i][1]),0)*source.settings.distanceScale)}));
const atlas={schema:1,source:{version:source.info.version,seed:source.info.seed,sha256:createHash('sha256').update(raw).digest('hex')},width:source.info.width,height:source.info.height,regions,terrain,borders,rivers,routes,settlements:world.settlements};
fs.writeFileSync('data/world/atlas.json',JSON.stringify(atlas));
console.log(JSON.stringify({regions:regions.length,terrain:terrain.length,routes:routes.length,rivers:rivers.length,settlements:world.settlements.length}));
