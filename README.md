# Wolters-Genetics-2018

consolidate_data.R was used to consolidate all data from the analyzed images into a single file which included all necessary identifying information for each individual spot including Strain ID, growth conditions, and time points.

compare_size_haploids.R was used to process the consolidated data to remove data points designed to be excluded from analysis (outer rings of spots and contaminated spots). The script then converted the consolidated size data for the putative recombinants generated from haploid strains representing different mitonuclear combinations in the 9x9 collection into a single size metric defined as size at 48 hours - size at time 0.

compare_size_diploids.R was used to process the consolidated data to remove data points designed to be excluded from analysis (outer rings of spots and contaminated spots). The script then converted the consolidated size data for the putative recombinants generated from crossing YJM975 and Y12 mitotypes into a single size metric defined as size at 48 hours - size at time 0.
