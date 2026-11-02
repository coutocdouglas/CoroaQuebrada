import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createHash} from 'node:crypto';
import {importWorld} from '../tools/import-azgaar.mjs';
const raw=fs.readFileSync(new URL('../data/world/source/azgaar-full.json',import.meta.url),'utf8');
const source=JSON.parse(raw);
const catalog=JSON.parse(fs.readFileSync(new URL('../data/world/catalog.json',import.meta.url),'utf8').replace(/^\uFEFF/,''));
const atlas=JSON.parse(fs.readFileSync(new URL('../data/world/atlas.json',import.meta.url),'utf8'));
test('real Azgaar 1.156 export imports all regions and their seats',()=>{
 const world=importWorld(source,catalog);
 assert.equal(world.regions.length,12);assert.equal(world.settlements.length,68);
 assert.equal(world.routes.length,62);
 for(const r of atlas.regions)assert.ok(world.settlements.find(b=>b.id===r.seat_id&&b.region===r.id),r.name);
 assert.equal(source.pack.burgs[source.pack.states[1].capital].name,'Porto da Coroa');
 assert.ok(source.pack.burgs[source.pack.states[1].capital].port);
 assert.equal(atlas.source.sha256,createHash('sha256').update(raw).digest('hex'));
});
test('all regions are reachable through borders or generated maritime paths',()=>{
 const neighbors=new Map(atlas.regions.map(r=>[r.id,new Set(r.neighbors)]));
 for(const route of atlas.routes) for(const a of route.regions) for(const b of route.regions)neighbors.get(a).add(b);
 const seen=new Set(['coroa']),todo=['coroa'];
 while(todo.length)for(const n of neighbors.get(todo.pop()))if(!seen.has(n)){seen.add(n);todo.push(n);}
 assert.equal(seen.size,12);assert.ok(atlas.routes.some(r=>r.regions.includes('ilhas')&&r.group==='searoutes'));
 for(const r of atlas.regions)for(const n of r.neighbors)assert.ok(neighbors.get(n).has(r.id));
});
test('prepared polygons and route coordinates are finite and seats use stable IDs',()=>{
 for(const c of atlas.terrain){assert.ok(c.polygon.length>=3);for(const p of c.polygon)assert.ok(p.every(Number.isFinite));}
 assert.equal(new Set(atlas.settlements.map(b=>b.id)).size,68);
 for(const route of atlas.routes){assert.ok(route.points.length>=2);assert.ok(route.length_km>=0);}
 assert.ok(atlas.terrain.some(c=>c.region===''));
});
