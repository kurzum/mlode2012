
select 'Disabling indexing...';
--# set index mode to manual
DB.DBA.VT_BATCH_UPDATE ('DB.DBA.RDF_OBJ', 'ON', NULL);

select 'Clearing existing data...';
-- Add here all the graphs we use for a clean update (RDF_GLOBAL_RESET deletes them all)
--SPARQL CLEAR GRAPH <http://mlode.nlp2rdf.org>;
RDF_GLOBAL_RESET();

-- Deleting previous entries of loader script
delete from DB.DBA.load_list;

-- see http://www.openlinksw.com/dataspace/dav/wiki/Main/VirtBulkRDFLoader
select 'Loading data...';
ld_dir ('/root/dimitris/data/mlode.nlp2rdf.org', '*.gz', 'http://mlode.nlp2rdf.org');

rdf_loader_run();

-- See if we have any errors
select * from DB.DBA.load_list where ll_state <> 2;

select 'Re-installing fct vad';
-- RDF_GLOBAL_RESET(); clears some stuff from this too, re-installing it restores them
-- takes longer but cleaned on what graghs to clear
DB.DBA.VAD_UNINSTALL('fct/1.11.98');
DB.DBA.VAD_INSTALL('/root/dimitris/virtuoso_mlode/share/virtuoso/vad/fct_dav.vad',0);

--# re-enable auto-index
select 'Re-enabling auto-indexing';
DB.DBA.RDF_OBJ_FT_RULE_ADD (null, null, 'All');
DB.DBA.VT_INC_INDEX_DB_DBA_RDF_OBJ ();
select 'Label auto-completion';
urilbl_ac_init_db();
select 'Ranking creation';
s_rank();
