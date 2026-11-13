params.motus_min_len_align_length = 75
params.motus_map_mgs_cutoff = 3

process motus {
	tag "mOTUs for $sample_id"

	input:
	tuple val(sample_id), path(reads)
	path(motus_db_path)

	output:
	path "motus_${sample_id}.out", emit: motus_res
	path "versions_motus_a.yml", emit: versions

	script:
	"""
	POLARS_SKIP_CPU_CHECK=1
	if [ -e ${reads[2]} ]
	then
		motus profile -n ${sample_id} -t $task.cpus \
			-db ${motus_db_path} \
			-l ${params.motus_min_len_align_length} -g ${params.motus_map_mgs_cutoff} \
			-f ${reads[0]} -r ${reads[1]} -s ${reads[2]} -o motus_${sample_id}.out
	else
		motus profile -n ${sample_id} -t $task.cpus \
			-db ${motus_db_path} \
			-l ${params.motus_min_len_align_length} -g ${params.motus_map_mgs_cutoff} \
			-f ${reads[0]} -r ${reads[1]} -o motus_${sample_id}.out
	fi

	bwa 2> bwa.version || true
	cat <<-END_VERSIONS > versions_motus_a.yml
	"${task.process}":
	    bwa: \$( cat bwa.version | grep Version | sed -e "s/Version: //g" )
	    samtools: \$( samtools --version | head -n 1 | sed -e "s/samtools //g" )
	    python: \$( python --version | sed -e "s/Python //g" )
	    motus: \$( cat ${motus_db_path}/*versions | head -n 1 | sed -e "s/motus\\t//g" )
	END_VERSIONS
	"""
}

process collate_motus { 
	publishDir params.outdir + "/classification", mode: params.publish_mode, pattern: "motus_all*"

	input:
	path(motus_res)
	path(motus_db_path)

	output:
	path "motus_all.tsv", emit: motus_all
	path "versions_motus_final.yml", emit: versions

	script:
	"""
	motus merge -i ${motus_res} -o motus_all.tsv -db ${motus_db_path}

	cat <<-END_VERSIONS > versions_motus_final.yml
	"${task.process}":
	    motus_all.tsv: \$( md5sum motus_all.tsv | sed -e "s/\\s.*//g" )
	END_VERSIONS
	"""
}

