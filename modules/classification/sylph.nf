process sylph {
    tag "sylph for $sample_id"

	input:
	tuple val(sample_id), path(reads)
	path(sylph_db_path)
    path(sylph_tax_path)

	output:
	path "sylph_${sample_id}.out", emit: sylph_res
	path "versions_sylph.yml", emit: versions

	script:
	"""
    sylph profile ${sylph_db_path} -1 ${reads[0]} -2 ${reads[1]} \
        -t ${task.cpus} -o ${sample_id}.tsv
    sylph-tax taxprof ${sample_id}.tsv -t ${sylph_tax_path} -o 'sylph_'
    mv *.sylphmpa sylph_${sample_id}.out

    cat <<-END_VERSIONS > versions_sylph.yml
	"${task.process}":
	    sylph: \$( sylph -V | sed -e "s/sylph //g" )
	    sylph-tax: \$( sylph-tax --version )
	END_VERSIONS
    """
}

process collate_sylph {
	publishDir params.outdir + "/classification/", mode: params.publish_mode, pattern: "sylph_all*"

	input:
	path(sylph_res)

	output:
	path "sylph_all_relab.tsv", emit: sylph_relateive_abundance
	path "sylph_all_seqab.tsv", emit: sylph_sequence_abundance
	path "versions_sylph_final.yml", emit: versions

	script:
	"""
	sylph-tax merge *.out --column relative_abundance -o sylph_all_relab.tsv
	sylph-tax merge *.out --column sequence_abundance -o sylph_all_seqab.tsv

	cat <<-END_VERSIONS > versions_sylph_final.yml
	"${task.process}":
	    sylph_all_relab.tsv: \$( md5sum sylph_all_relab.tsv | sed -e "s/\\s.*//g" )
	    sylph_all_seqab.tsv: \$( md5sum sylph_all_seqab.tsv | sed -e "s/\\s.*//g" )
	END_VERSIONS
	"""
}