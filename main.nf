process run_hifiasm {
    publishDir "${params.outdir}/hifiasm", mode: 'symlink'
    input:
    path fastq_reads
    path hic1
    path hic2

    output:
    path "${params.id}.hic.p_ctg.fa", emit: primary_asm
    path "hifiasm.log", emit: hifiasm_log

    script:
    """
    hifiasm -t ${params.nthreads} \\
    --h1 ${hic1} \\
    --h2 ${hic2} \\
    -o ${params.id} \\
    ${fastq_reads}

    awk '/^S/{print ">"$2;print $3}' \\
        ${params.id}.hic.p_ctg.gfa > ${params.id}.hic.p_ctg.fa
    """
}


process clean_assembly {
    publishDir "${params.outdir}/fcs", mode: 'symlink'
    
    stageInMode 'copy'
    conda params.nextflow_env
    input:
    path genome_asm

    output:
    "results/cleaned_adapter_removed/${params.id}.cleaned.adapter_removed.fasta",  emit :screened_assembly

    script:
    """
    nextflow run artorias111/fcs_nf --fasta \$PWD/${genome_asm} \\
    --taxid ${params.taxid} \\
    --specimen_id ${params.id} \\
    --outdir .
    """
}

process scaffold {
    publishDir "${params.outdir}/yahs", mode: 'symlink'
    input:
    path cleaned_asm
    path hic1
    path hic2

    output:
    path "yahs.out_scaffolds_final.fa", emit: scaffolded_assembly
    path "out_JBAT.assembly", emit_contact_matrix_asm
    path "out_JBAT.hic", emit: contact_matrix

    script:
    """
    ${projectDir}/bin/YaHS-Contact-map_pipeline \\
    -g ${cleaned_asm} \\
    -a ${hic1} \\
    -b ${hic2}
    """
}


workflow {
    
}
