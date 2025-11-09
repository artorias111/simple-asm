// include modules

include { busco as busco_hifiasm } from './bin/busco.nf'
include { busco as busco_cleaned } from './bin/busco.nf'
include { busco as busco_scaffolded } from './bin/busco.nf'
include { quast as quast_hifiasm } from './bin/quast.nf'
include { quast as quast_cleaned } from './bin/quast.nf'
include { quast as quast_scaffolded } from './bin/quast.nf'

// Define processes

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
    ${fastq_reads} > hifiasm.log 2>&1

    awk '/^S/{print ">"\$2;print \$3}' \\
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
    path "results/cleaned_adapter_removed/${params.id}.cleaned.adapter_removed.fasta", emit: screened_assembly

    script:
    """
    nextflow run artorias111/fcs_nf --fasta \$PWD/${genome_asm} \\
    --taxid ${params.taxid} \\
    --specimen_id ${params.id} \\
    --outdir .
    """
}

process scaffold {

    errorStrategy { task.exitStatus == 56 ? 'ignore' : 'terminate' }

    conda params.bwamem2_env

    publishDir "${params.outdir}/yahs", mode: 'symlink'
    input:
    path cleaned_asm
    path hic1
    path hic2

    output:
    path "yahs.out_scaffolds_final.fa", emit: scaffolded_assembly
    path "out_JBAT.assembly", emit: contact_matrix_asm
    path "out_JBAT.hic", emit: contact_matrix

    script:
    """
    samtools faidx ${cleaned_asm}
    ${projectDir}/bin/YaHS-Contact-map_pipeline \\
    -g ${cleaned_asm} \\
    -a ${hic1} \\
    -b ${hic2}
    """
}

workflow {
    // Define input channels
    Channel
        .fromPath("${params.hifi_reads}/*.fastq.gz")
        .filter { !it.name.contains('fail') }
        .filter { !it.name.contains('gz.') }
        .collect()
        .set { fastq_ch }

    hic1_ch = Channel.fromPath(params.hic1)
    hic2_ch = Channel.fromPath(params.hic2)
    
    // Run hifiasm assembly
    run_hifiasm(fastq_ch, hic1_ch, hic2_ch)
    
    // QC after hifiasm
    quast_hifiasm(run_hifiasm.out.primary_asm)
    busco_hifiasm(run_hifiasm.out.primary_asm)
    
    // Clean assembly (remove adapters and contaminants)
    clean_assembly(run_hifiasm.out.primary_asm)
    
    // QC after cleanup
    quast_cleaned(clean_assembly.out.screened_assembly)
    busco_cleaned(clean_assembly.out.screened_assembly)
    
    // Scaffold with Hi-C data
    scaffold(
        clean_assembly.out.screened_assembly,
        hic1_ch,
        hic2_ch
    )
    
    // QC after scaffolding
    quast_scaffolded(scaffold.out.scaffolded_assembly)
    busco_scaffolded(scaffold.out.scaffolded_assembly)
}
