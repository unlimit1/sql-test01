select count(1) 
  from chembl_ana.pq_assays a
       left join chembl_ana.pq_activities act on a.assay_id = act.assay_id -- 15,504,603 -> 15,504,805 (act 없는 a 가 202건...
       left join chembl_ana.pq_target_dictionary td on a.tid = td.tid  -- 15,504,805
       left join chembl_ana.pq_compound_structures2 cs on act.molregno = cs.molregno -- 15,504,805
       left join chembl_ana.pq_molecule_dictionary md on act.molregno = md.molregno -- 15,504,805       
;

select target_type, count(1) cnt from chembl_ana.pq_target_dictionary group by target_type order by cnt desc;
/*target_type	cnt
SINGLE PROTEIN	7,350
ORGANISM	2,137
CELL-LINE	1,608
PROTEIN COMPLEX	424
PROTEIN FAMILY	335
TISSUE	243
SELECTIVITY GROUP	100
PROTEIN-PROTEIN INTERACTION	80
PROTEIN COMPLEX GROUP	53
NUCLEIC-ACID	33
SMALL MOLECULE	25
*/

select td.target_type, count(1) cnt
  from chembl_ana.pq_assays a
       left join chembl_ana.pq_activities act on a.assay_id = act.assay_id -- 15,504,603 -> 15,504,805
       left join chembl_ana.pq_target_dictionary td on a.tid = td.tid  -- 15,504,805
       left join chembl_ana.pq_compound_structures2 cs on act.molregno = cs.molregno -- 15,504,805
       left join chembl_ana.pq_molecule_dictionary md on act.molregno = md.molregno -- 15,504,805    
 where 1=1
   and cs.canonical_smiles is not null -- 15,367,297         
 group by td.target_type order by cnt desc   
;
/*target_type	cnt
SINGLE PROTEIN	6,236,292
CELL-LINE	3,562,281
ORGANISM	2,746,697
UNCHECKED	1,617,379
NON-MOLECULAR	308,217
ADMET	171,685
NO TARGET	127,186
PROTEIN COMPLEX	115,645
PROTEIN FAMILY	91,003
PROTEIN-PROTEIN INTERACTION	88,312
NUCLEIC-ACID	85,912
TISSUE	82,608
PROTEIN COMPLEX GROUP	30,412
UNKNOWN	28,011
PHENOTYPE	26,279
SUBCELLULAR	26,202
SELECTIVITY GROUP	21,601
CHIMERIC PROTEIN	1,444
SMALL MOLECULE	87
MACROMOLECULE	44
*/

-- -------------------------------------------
-- single protein 과 gene_symbol 연결해 보기...

select * from chembl_ana.pq_target_components order by tid;

with t_gs as
(  -- 10,455건 존재, 28건만 다수 gene_symble 존재
select tc.tid, csy.syns gene_symbol
  from chembl_ana.pq_target_components tc
       inner join (
                  select component_id
					      -- ,listagg (syn_type,' ') within group (order by syn_type) syns
					      -- ,group_concat(component_synonym separator ', ') syns
					      ,array_join(array_agg(component_synonym), ',') syns
						  from chembl_ana.pq_component_synonyms
						 where syn_type = 'GENE_SYMBOL'
						 group by component_id
                 ) csy on tc.component_id = csy.component_id
)
select count(1) from t_gs ; -- where gene_symbol like '%,%'; 

-- --------------------------------------------------------------------
--  chembl25 compound - target association 
--    중복포함 : 6,236,292 건   중복제거 : 4,907,359 건 
with t_gs as
(  -- 10,455건 존재, 28건만 다수 gene_symble 존재
select tc.tid, csy.syns gene_symbol
  from chembl_ana.pq_target_components tc
       inner join (
                  select component_id
					      -- ,listagg (syn_type,' ') within group (order by syn_type) syns
					      -- ,group_concat(component_synonym separator ', ') syns
					      ,array_join(array_agg(component_synonym), ',') syns
						  from chembl_ana.pq_component_synonyms
						 where syn_type = 'GENE_SYMBOL'
						 group by component_id
                 ) csy on tc.component_id = csy.component_id
)
, rslt as (
select -- count(1) cnt -- 6236292
       act.molregno, cs.canonical_smiles, td.tid, tgs.gene_symbol, td.organism
      ,a.assay_id chembl_assay_id, md.chembl_id compound_chembl_id, cs.standard_inchi_key, td.chembl_id target_chembl_id, td.target_type, td.tax_id
      ,a.description, act.standard_type, act.standard_relation, act.standard_value, act.standard_units, act.standard_text_value
      ,row_number() over (partition by act.molregno, td.tid order by act.activity_id desc) odr
  from chembl_ana.pq_assays a
       left join chembl_ana.pq_activities act on a.assay_id = act.assay_id -- 15,504,603 -> 15,504,805
       left join chembl_ana.pq_target_dictionary td on a.tid = td.tid  -- 15,504,805
       left join chembl_ana.pq_compound_structures2 cs on act.molregno = cs.molregno -- 15,504,805
       left join chembl_ana.pq_molecule_dictionary md on act.molregno = md.molregno -- 15,504,805    
       left join t_gs tgs on td.tid = tgs.tid
 where 1=1
   and cs.canonical_smiles is not null -- 15,367,297         
   and td.target_type = 'SINGLE PROTEIN' -- 6,236,292
   -- and tgs.gene_symbol not like '%,%' 5,977,464
 --order by act.molregno, td.tid, act.activity_id desc   
)
select * from rslt -- where odr = 1 -- 4907359
 order by compound_chembl_id, lower(gene_symbol)
 limit 10000
;

