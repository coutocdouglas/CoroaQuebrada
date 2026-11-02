import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {importWorld} from '../tools/import-azgaar.mjs';
const catalog=JSON.parse(fs.readFileSync(new URL('../data/world/catalog.json',import.meta.url),'utf8').replace(/^\uFEFF/,''));
// Small synthetic geography following the official export-json.ts contract.
function fixture(){return {info:{width:100,height:100,version:'contract-test'},settings:{populationRate:1000},pack:{
 provinces:[0,...catalog.regions.map((r,i)=>({i:i+1,state:1,name:r.name}))],
 vertices:[{i:0,p:[0,0]},{i:1,p:[1,0]},{i:2,p:[0,1]}],
 cells:catalog.regions.map((_,i)=>({i,h:30,state:1,province:i+1,v:[0,1,2],c:i<11?[i+1]:[],pop:2,biome:6})),
 burgs:[{i:1,name:'Porto',cell:0,x:0.5,y:0.5,population:4,port:1}],
 routes:[{i:0,group:'roads',points:[[0,0,0],[1,1,1]]}],rivers:[]}};}
test('imports twelve regions, terrain, settlement and route without changing input',()=>{
 const source=fixture(),before=JSON.stringify(source); const world=importWorld(source,catalog);
 assert.equal(world.regions.length,12); assert.equal(world.cells.length,12);
 assert.equal(world.settlements[0].region,'coroa'); assert.equal(world.settlements[0].port,true);
 assert.equal(world.routes[0].status,'geography_only'); assert.equal(JSON.stringify(source),before);
 assert.equal(world.regions[0].population_raw,2); assert.deepEqual(world.regions[0].neighbors,['vale']);
 assert.equal(world.stock,undefined);
});
for(const [name,edit] of [
 ['missing geometry',s=>delete s.pack.vertices],
 ['wrong regions',s=>s.pack.provinces.pop()],
 ['unassigned territory',s=>s.pack.cells[0].province=100],
 ['broken polygon',s=>s.pack.cells[0].v=[0,1,900]],
 ['missing neighbor',s=>s.pack.cells[0].c=[100]],
 ['negative population',s=>s.pack.cells[0].pop=-1],
 ['bad route',s=>s.pack.routes[0].points=[[0,0,0],[null,1,1]]],
 ['bad settlement',s=>s.pack.burgs[0].x=null],
 ['duplicate cells',s=>s.pack.cells.push(s.pack.cells[0])],
 ['wrong dimensions',s=>s.info.width=0]
]) test(`rejects ${name}`,()=>{const source=fixture();edit(source);assert.throws(()=>importWorld(source,catalog));});
test('foreign land is retained as external neighbor, not merged into the kingdom',()=>{
 const s=fixture();s.pack.cells.push({i:12,h:40,state:2,province:1});s.pack.cells[0].c=[12];
 const w=importWorld(s,catalog);assert.equal(w.cells.length,12);assert.deepEqual(w.regions[0].neighbors,[]);
});
