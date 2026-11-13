#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { workflowVersionToYAML } from '../modules/utils'

include { input_check } from '../modules/input/input_check'

/* CLASSIFICATION
 * Processes for motus, metaphlan, phanta (including kraken2)
*/

include { motus } from  '../modules/classification/motus'
include { collate_motus } from '../modules/classification/motus'
include { metaphlan } from '../modules/classification/metaphlan'
include { collate_metaphlan } from '../modules/classification/metaphlan'
include { sylph } from '../modules/classification/sylph'
include { collate_sylph } from '../modules/classification/sylph'

workflow {

	// Input
	ch_processed_reads = input_check()
	ch_versions = channel.empty()

	// CLASSIFICATION
	
	// motus
	ch_motus = motus(ch_processed_reads.reads, params.motus_db_path)
	ch_all_motus = collate_motus(ch_motus.motus_res.collect(), 
		params.motus_db_path)
	ch_versions = ch_versions.mix(ch_motus.versions.first())
	ch_versions = ch_versions.mix(ch_all_motus.versions.first())	
	
	// Metaphlan
	ch_metaphlan = metaphlan(ch_processed_reads.reads, params.metaphlan_db_path)
	ch_all_metaphlan = collate_metaphlan(ch_metaphlan.metaphlan_res.collect(), 
		ch_metaphlan.metaphlan_res_gtdb.collect())
	ch_versions = ch_versions.mix(ch_metaphlan.versions.first())
	ch_versions = ch_versions.mix(ch_all_metaphlan.versions.first())
	
	// Sylph
	ch_sylph = sylph(ch_processed_reads.reads, params.sylph_db_path, params.sylph_tax_path)
	ch_all_sylph = collate_sylph(ch_sylph.sylph_res.collect())
	ch_versions = ch_versions.mix(ch_sylph.versions.first())
	ch_versions = ch_versions.mix(ch_all_sylph.versions.first())

	// VERSION output
	ch_versions
		.unique()
		.mix( channel.of(workflowVersionToYAML()) )
		.collectFile(name: params.outdir + '/versions_classification.yml', 
		newLine: true)
}
