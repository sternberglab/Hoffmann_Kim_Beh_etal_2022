# Hoffmann_Kim_Beh_etal_2022

This repository contains the code for analyzing and interpreting Illumina sequencing data for chromatin immunoprecipitation (ChIP). 
This README files provides information on all upladed documents files. 

## File descriptions

# E_coli_BL21_Reference_genomes
All reference genomes used in the ChIP-seq analyses were modified from E. coli BL21(DE3) (GenBank accession CP001509.3). We provide the .fasta 
and the indexed .fai files for each version of the reference genome. 
The addition 'masked' in the files indicates that two genomic lacZ/lacI regions and flanking regions, which are partially identical to plasmid-encoded sequences, were masked in all alignments (genomic coordinates 335,600-337,101 and 748,601-750,390)

# ChIP-seq_pipeline.txt
This file states the bioinformatic steps that were performed in the ChIP-seq analysis.

# ChIPseq_analysis_script_paired-end_reads_submission.sh
This file is a shell script and carries out quality filtering and read mapping (see ChIP-seq_pipeline.txt) for paired-end sequencing runs for ChIP-seq data analysis. Please refer to the well-annotated code for requirements, input/output files, and parameters.

# ChIPseq_analysis_script_single-end_reads_submission.sh
This file is a shell script and carries out quality filtering and read mapping (see ChIP-seq_pipeline.txt) for single-end sequencing runs for ChIP-seq data analysis. Please refer to the well-annotated code for requirements, input/output files, and parameters.

# Normalization_bamCoverage_RPKM_ChIPseq_analysis_script_submission.sh
This file is a shell script and carries out read normalization after quality filtering and read mapping (see ChIP-seq_pipeline.txt). Please refer to the well-annotated code for requirements, input/output files, and parameters.

