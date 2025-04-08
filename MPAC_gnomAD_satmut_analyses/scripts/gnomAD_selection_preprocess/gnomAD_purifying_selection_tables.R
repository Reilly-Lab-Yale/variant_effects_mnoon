#!/bin/R

# Take gnomAD tables, remap factors, collapse along dimensions, and perform statistical tests

# load libraries
library(tidyverse)
library(data.table)
library(wrapr)

# remap and collapse bins
mean_ref_pred_bin_map <- c(
	`mean_ref_(-Inf^-1)` = "[-Inf, 1)",
	`mean_ref_[-1^0)` = "[-Inf, 1)",
	`mean_ref_[0^1)` = "[-Inf, 1)",
	`mean_ref_[1^2)` = "[1, 2)",
	`mean_ref_[2^3)` = "[2, 3)",
	`mean_ref_[3^4)` = "[3, 4)",
	`mean_ref_[4^5)` = "[4, 5)",
	`mean_ref_[5^Inf)` = "[5, Inf)"
)

mean_skew_pred_bin_map <- c(
	`mean_skew_(-Inf^ -1&5)` = "(-Inf, -1.5)",
	`mean_skew_[-1&5^ -1&0)` = "[-1.5, -1.0)",
	`mean_skew_[-1&0^ -0&5)` = "[-1.0, -0.5)",
	`mean_skew_[-0&5^ -0&2)` = "[-0.5, -0.2)",
	`mean_skew_[-0&2^ -0&05)` = "[-0.2, -0.05)",
	`mean_skew_[-0&05^ -0&02)` = "[-0.05, 0.05)",
	`mean_skew_[-0&02^ 0)` = "[-0.05, 0.05)",
	`mean_skew_[0^ 0&02)` = "[-0.05, 0.05)",
	`mean_skew_[0&02^ 0&05)` = "[-0.05, 0.05)",
	`mean_skew_[0&05^ 0&2)` = "[0.05, 0.2)",
	`mean_skew_[0&2^ 0&5)` = "[0.2, 0.5)",
	`mean_skew_[0&5^ 1&0)` = "[0.5, 1.0)",
	`mean_skew_[1&0^ 1&5)` = "[1.0, 1.5)",
	`mean_skew_(1&5^ Inf)` = "[1.5, Inf)"
)

K562_ref_pred_bin_map <- mean_ref_pred_bin_map
names(K562_ref_pred_bin_map) <- gsub("mean", "K562", names(K562_ref_pred_bin_map))

K562_skew_pred_bin_map <- mean_skew_pred_bin_map
names(K562_skew_pred_bin_map) <- gsub("mean", "K562", names(K562_skew_pred_bin_map))

HepG2_ref_pred_bin_map <- mean_ref_pred_bin_map
names(HepG2_ref_pred_bin_map) <- gsub("mean", "HepG2", names(HepG2_ref_pred_bin_map))

HepG2_skew_pred_bin_map <- mean_skew_pred_bin_map
names(HepG2_skew_pred_bin_map) <- gsub("mean", "HepG2", names(HepG2_skew_pred_bin_map))

SKNSH_ref_pred_bin_map <- mean_ref_pred_bin_map
names(SKNSH_ref_pred_bin_map) <- gsub("mean", "SKNSH", names(SKNSH_ref_pred_bin_map))

SKNSH_skew_pred_bin_map <- mean_skew_pred_bin_map
names(SKNSH_skew_pred_bin_map) <- gsub("mean", "SKNSH", names(SKNSH_skew_pred_bin_map))

category_short_map <- c(
	`SINGLETON` = "RARE",
	`ULTRARARE` = "RARE",
	`RARE` = "RARE",
	`LOW_FREQ` = "COMMON",
	`COMMON` = "COMMON"
)

ENCODE_cCREs_map <- c(
	# least to greatest
	`is_in_PLS` = "PLS",
	`is_in_pELS` = "pELS",
	`is_in_dELS` = "dELS",
	`is_in_Low_DNase` = "non-cCRE",
	`is_in_CA-TF` = "Other cCREs",
	`is_in_CA-H3K4me3` = "Other cCREs",
	`is_in_TF` = "Other cCREs",
	`is_in_CA-CTCF` = "Other cCREs",
	`is_in_CA` = "Other cCREs"
)

CADD_bin_map <- c(
	# least to greatest
	`CADD>=0` = "CADD>=0",
	`CADD>=10` = "CADD>=10",
	`CADD>=20` = "CADD>=20",
	`CADD>=30` = "CADD>=30",
	`CADD>=40` = "CADD>=40",
	`CADD>=50` = "CADD>=50"
)

emVar_category_colors <- c(
	"none" = "grey50", 
	"K562" = "#00A79D",
	"HepG2" = "#FBB040", 
	"SKNSH" = "#ED1C24", 
	"K562+HepG2" = "#66c2a5", 
	"K562+SKNSH" = "#8da0cb",
	"SKNSH+HepG2" = "#fc8d62", 
	"K562+SKNSH+HepG2" = "#e78ac3"
)


emVar_category_pleio <- c(
	"none" = 0, 
	"K562" = 1,
	"HepG2" = 1, 
	"SKNSH" = 1, 
	"K562+HepG2" = 2, 
	"K562+SKNSH" = 2,
	"SKNSH+HepG2" = 2, 
	"K562+SKNSH+HepG2" = 3
)

# # # 

# load tables
gnomAD_main_table <- as_tibble(fread("../../data/gnomAD_mackenzie_processed/malinois_all_v3/part-00000-f0ba68db-ede3-47d3-8c60-ca01572c89ee-c000.csv.gz"))
names(gnomAD_main_table) <- gsub("__", "_", names(gnomAD_main_table))

# preprocessing pivots
# add emVar categories
gnomAD_main_table <- gnomAD_main_table %>% 
	mutate(emVar_category = 
		case_when(
			emVar_K562 & emVar_SKNSH & emVar_HepG2 ~ "K562+SKNSH+HepG2",
			emVar_K562 & emVar_SKNSH ~ "K562+SKNSH",
			emVar_K562 & emVar_HepG2 ~ "K562+HepG2",
			emVar_SKNSH & emVar_HepG2 ~ "SKNSH+HepG2",
			emVar_K562 ~ "K562",
			emVar_HepG2 ~ "HepG2",
			emVar_SKNSH ~ "SKNSH",
			.default = "none"
		)
	) %>% 
	mutate(
		emVar_category = factor(emVar_category, levels = names(emVar_category_colors))
	) %>% 
	dplyr::select(
		-emVar_K562, 
		-emVar_HepG2, 
		-emVar_SKNSH
	)

gnomAD_main_table <- gnomAD_main_table %>% 
	rowwise() %>% mutate(`is_in_Low_DNase` = !any(`is_in_dELS`, `is_in_CA`, `is_in_pELS`, `is_in_CA-H3K4me3`, `is_in_CA-CTCF`, `is_in_PLS`, `is_in_TF`, `is_in_CA-TF`)) %>% ungroup() %>% 
	rowwise() %>% mutate(`CADD>=0` = !any(`CADD>=10`, `CADD>=20`, `CADD>=30`, `CADD>=40`, `CADD>=50`)) %>% ungroup()

gnomAD_main_table <- gnomAD_main_table %>% 
	mutate(CADD_bin = ifelse(`CADD>=50`, "CADD>=50", ifelse(`CADD>=40`, "CADD>=40", ifelse(`CADD>=30`, "CADD>=30", ifelse(`CADD>=20`, "CADD>=20", ifelse(`CADD>=10`, "CADD>=10", ifelse(`CADD>=0`, "CADD>=0", NA))))))) %>% dplyr::select(-starts_with("CADD>=")) %>% 
	mutate(ENCODE_cCREs = ifelse(`is_in_Low_DNase`, "is_in_Low_DNase", ifelse(`is_in_dELS`, "is_in_dELS", ifelse(`is_in_CA`, "is_in_CA", ifelse(`is_in_pELS`, "is_in_pELS", ifelse(`is_in_CA-H3K4me3`, "is_in_CA-H3K4me3", ifelse(`is_in_CA-CTCF`, "is_in_CA-CTCF", ifelse(`is_in_PLS`, "is_in_PLS", ifelse(`is_in_TF`, "is_in_TF", ifelse(`is_in_CA-TF`, "is_in_CA-TF", NA)))))))))) %>% dplyr::select(-names(ENCODE_cCREs_map))

gnomAD_main_table <- gnomAD_main_table %>% 
	mutate(mean_ref_pred_bin = ifelse(`mean_ref_(-Inf^-1)`, "mean_ref_(-Inf^-1)", ifelse(`mean_ref_[-1^0)`, "mean_ref_[-1^0)", ifelse(`mean_ref_[0^1)`, "mean_ref_[0^1)", ifelse(`mean_ref_[1^2)`, "mean_ref_[1^2)", ifelse(`mean_ref_[2^3)`, "mean_ref_[2^3)", ifelse(`mean_ref_[3^4)`, "mean_ref_[3^4)", ifelse(`mean_ref_[4^5)`, "mean_ref_[4^5)", ifelse(`mean_ref_[5^Inf)`, "mean_ref_[5^Inf)", NA))))))))) %>% dplyr::select(-starts_with("mean_ref_("), -starts_with("mean_ref_[")) %>% 
	mutate(mean_skew_pred_bin = ifelse(`mean_skew_(-Inf^ -1&5)`, "mean_skew_(-Inf^ -1&5)", ifelse(`mean_skew_[-1&5^ -1&0)`, "mean_skew_[-1&5^ -1&0)", ifelse(`mean_skew_[-1&0^ -0&5)`, "mean_skew_[-1&0^ -0&5)", ifelse(`mean_skew_[-0&5^ -0&2)`, "mean_skew_[-0&5^ -0&2)", ifelse(`mean_skew_[-0&2^ -0&05)`, "mean_skew_[-0&2^ -0&05)", ifelse(`mean_skew_[-0&05^ -0&02)`, "mean_skew_[-0&05^ -0&02)", ifelse(`mean_skew_[-0&02^ 0)`, "mean_skew_[-0&02^ 0)", 
		ifelse(`mean_skew_[0^ 0&02)`, "mean_skew_[0^ 0&02)", ifelse(`mean_skew_[0&02^ 0&05)`, "mean_skew_[0&02^ 0&05)", ifelse(`mean_skew_[0&05^ 0&2)`, "mean_skew_[0&05^ 0&2)", ifelse(`mean_skew_[0&2^ 0&5)`, "mean_skew_[0&2^ 0&5)", ifelse(`mean_skew_[0&5^ 1&0)`, "mean_skew_[0&5^ 1&0)", ifelse(`mean_skew_[1&0^ 1&5)`, "mean_skew_[1&0^ 1&5)", ifelse(`mean_skew_(1&5^ Inf)`, "mean_skew_(1&5^ Inf)", NA))))))))))))))) %>% dplyr::select(-starts_with("mean_skew_("), -starts_with("mean_skew_["))

gnomAD_main_table <- gnomAD_main_table %>% 
	mutate(K562_ref_pred_bin = ifelse(`K562_ref_(-Inf^-1)`, "K562_ref_(-Inf^-1)", ifelse(`K562_ref_[-1^0)`, "K562_ref_[-1^0)", ifelse(`K562_ref_[0^1)`, "K562_ref_[0^1)", ifelse(`K562_ref_[1^2)`, "K562_ref_[1^2)", ifelse(`K562_ref_[2^3)`, "K562_ref_[2^3)", ifelse(`K562_ref_[3^4)`, "K562_ref_[3^4)", ifelse(`K562_ref_[4^5)`, "K562_ref_[4^5)", ifelse(`K562_ref_[5^Inf)`, "K562_ref_[5^Inf)", NA))))))))) %>% dplyr::select(-starts_with("K562_ref_("), -starts_with("K562_ref_[")) %>% 
	mutate(K562_skew_pred_bin = ifelse(`K562_skew_(-Inf^ -1&5)`, "K562_skew_(-Inf^ -1&5)", ifelse(`K562_skew_[-1&5^ -1&0)`, "K562_skew_[-1&5^ -1&0)", ifelse(`K562_skew_[-1&0^ -0&5)`, "K562_skew_[-1&0^ -0&5)", ifelse(`K562_skew_[-0&5^ -0&2)`, "K562_skew_[-0&5^ -0&2)", ifelse(`K562_skew_[-0&2^ -0&05)`, "K562_skew_[-0&2^ -0&05)", ifelse(`K562_skew_[-0&05^ -0&02)`, "K562_skew_[-0&05^ -0&02)", ifelse(`K562_skew_[-0&02^ 0)`, "K562_skew_[-0&02^ 0)", 
		ifelse(`K562_skew_[0^ 0&02)`, "K562_skew_[0^ 0&02)", ifelse(`K562_skew_[0&02^ 0&05)`, "K562_skew_[0&02^ 0&05)", ifelse(`K562_skew_[0&05^ 0&2)`, "K562_skew_[0&05^ 0&2)", ifelse(`K562_skew_[0&2^ 0&5)`, "K562_skew_[0&2^ 0&5)", ifelse(`K562_skew_[0&5^ 1&0)`, "K562_skew_[0&5^ 1&0)", ifelse(`K562_skew_[1&0^ 1&5)`, "K562_skew_[1&0^ 1&5)", ifelse(`K562_skew_(1&5^ Inf)`, "K562_skew_(1&5^ Inf)", NA))))))))))))))) %>% dplyr::select(-starts_with("K562_skew_("), -starts_with("K562_skew_["))

gnomAD_main_table <- gnomAD_main_table %>% 
	mutate(HepG2_ref_pred_bin = ifelse(`HepG2_ref_(-Inf^-1)`, "HepG2_ref_(-Inf^-1)", ifelse(`HepG2_ref_[-1^0)`, "HepG2_ref_[-1^0)", ifelse(`HepG2_ref_[0^1)`, "HepG2_ref_[0^1)", ifelse(`HepG2_ref_[1^2)`, "HepG2_ref_[1^2)", ifelse(`HepG2_ref_[2^3)`, "HepG2_ref_[2^3)", ifelse(`HepG2_ref_[3^4)`, "HepG2_ref_[3^4)", ifelse(`HepG2_ref_[4^5)`, "HepG2_ref_[4^5)", ifelse(`HepG2_ref_[5^Inf)`, "HepG2_ref_[5^Inf)", NA))))))))) %>% dplyr::select(-starts_with("HepG2_ref_("), -starts_with("HepG2_ref_[")) %>% 
	mutate(HepG2_skew_pred_bin = ifelse(`HepG2_skew_(-Inf^ -1&5)`, "HepG2_skew_(-Inf^ -1&5)", ifelse(`HepG2_skew_[-1&5^ -1&0)`, "HepG2_skew_[-1&5^ -1&0)", ifelse(`HepG2_skew_[-1&0^ -0&5)`, "HepG2_skew_[-1&0^ -0&5)", ifelse(`HepG2_skew_[-0&5^ -0&2)`, "HepG2_skew_[-0&5^ -0&2)", ifelse(`HepG2_skew_[-0&2^ -0&05)`, "HepG2_skew_[-0&2^ -0&05)", ifelse(`HepG2_skew_[-0&05^ -0&02)`, "HepG2_skew_[-0&05^ -0&02)", ifelse(`HepG2_skew_[-0&02^ 0)`, "HepG2_skew_[-0&02^ 0)", 
		ifelse(`HepG2_skew_[0^ 0&02)`, "HepG2_skew_[0^ 0&02)", ifelse(`HepG2_skew_[0&02^ 0&05)`, "HepG2_skew_[0&02^ 0&05)", ifelse(`HepG2_skew_[0&05^ 0&2)`, "HepG2_skew_[0&05^ 0&2)", ifelse(`HepG2_skew_[0&2^ 0&5)`, "HepG2_skew_[0&2^ 0&5)", ifelse(`HepG2_skew_[0&5^ 1&0)`, "HepG2_skew_[0&5^ 1&0)", ifelse(`HepG2_skew_[1&0^ 1&5)`, "HepG2_skew_[1&0^ 1&5)", ifelse(`HepG2_skew_(1&5^ Inf)`, "HepG2_skew_(1&5^ Inf)", NA))))))))))))))) %>% dplyr::select(-starts_with("HepG2_skew_("), -starts_with("HepG2_skew_["))

gnomAD_main_table <- gnomAD_main_table %>% 
	mutate(SKNSH_ref_pred_bin = ifelse(`SKNSH_ref_(-Inf^-1)`, "SKNSH_ref_(-Inf^-1)", ifelse(`SKNSH_ref_[-1^0)`, "SKNSH_ref_[-1^0)", ifelse(`SKNSH_ref_[0^1)`, "SKNSH_ref_[0^1)", ifelse(`SKNSH_ref_[1^2)`, "SKNSH_ref_[1^2)", ifelse(`SKNSH_ref_[2^3)`, "SKNSH_ref_[2^3)", ifelse(`SKNSH_ref_[3^4)`, "SKNSH_ref_[3^4)", ifelse(`SKNSH_ref_[4^5)`, "SKNSH_ref_[4^5)", ifelse(`SKNSH_ref_[5^Inf)`, "SKNSH_ref_[5^Inf)", NA))))))))) %>% dplyr::select(-starts_with("SKNSH_ref_("), -starts_with("SKNSH_ref_[")) %>% 
	mutate(SKNSH_skew_pred_bin = ifelse(`SKNSH_skew_(-Inf^ -1&5)`, "SKNSH_skew_(-Inf^ -1&5)", ifelse(`SKNSH_skew_[-1&5^ -1&0)`, "SKNSH_skew_[-1&5^ -1&0)", ifelse(`SKNSH_skew_[-1&0^ -0&5)`, "SKNSH_skew_[-1&0^ -0&5)", ifelse(`SKNSH_skew_[-0&5^ -0&2)`, "SKNSH_skew_[-0&5^ -0&2)", ifelse(`SKNSH_skew_[-0&2^ -0&05)`, "SKNSH_skew_[-0&2^ -0&05)", ifelse(`SKNSH_skew_[-0&05^ -0&02)`, "SKNSH_skew_[-0&05^ -0&02)", ifelse(`SKNSH_skew_[-0&02^ 0)`, "SKNSH_skew_[-0&02^ 0)", 
		ifelse(`SKNSH_skew_[0^ 0&02)`, "SKNSH_skew_[0^ 0&02)", ifelse(`SKNSH_skew_[0&02^ 0&05)`, "SKNSH_skew_[0&02^ 0&05)", ifelse(`SKNSH_skew_[0&05^ 0&2)`, "SKNSH_skew_[0&05^ 0&2)", ifelse(`SKNSH_skew_[0&2^ 0&5)`, "SKNSH_skew_[0&2^ 0&5)", ifelse(`SKNSH_skew_[0&5^ 1&0)`, "SKNSH_skew_[0&5^ 1&0)", ifelse(`SKNSH_skew_[1&0^ 1&5)`, "SKNSH_skew_[1&0^ 1&5)", ifelse(`SKNSH_skew_(1&5^ Inf)`, "SKNSH_skew_(1&5^ Inf)", NA))))))))))))))) %>% dplyr::select(-starts_with("SKNSH_skew_("), -starts_with("SKNSH_skew_["))

gnomAD_main_table <- gnomAD_main_table %>% 
	mutate(mean_ref_pred_bin = factor(mean_ref_pred_bin_map[mean_ref_pred_bin], levels = unique(mean_ref_pred_bin_map))) %>% 
	mutate(mean_skew_pred_bin = factor(mean_skew_pred_bin_map[mean_skew_pred_bin], levels = unique(mean_skew_pred_bin_map))) %>% 
	mutate(K562_ref_pred_bin = factor(K562_ref_pred_bin_map[K562_ref_pred_bin], levels = unique(K562_ref_pred_bin_map))) %>% 
	mutate(K562_skew_pred_bin = factor(K562_skew_pred_bin_map[K562_skew_pred_bin], levels = unique(K562_skew_pred_bin_map))) %>% 
	mutate(HepG2_ref_pred_bin = factor(HepG2_ref_pred_bin_map[HepG2_ref_pred_bin], levels = unique(HepG2_ref_pred_bin_map))) %>% 
	mutate(HepG2_skew_pred_bin = factor(HepG2_skew_pred_bin_map[HepG2_skew_pred_bin], levels = unique(HepG2_skew_pred_bin_map))) %>% 
	mutate(SKNSH_ref_pred_bin = factor(SKNSH_ref_pred_bin_map[SKNSH_ref_pred_bin], levels = unique(SKNSH_ref_pred_bin_map))) %>% 
	mutate(SKNSH_skew_pred_bin = factor(SKNSH_skew_pred_bin_map[SKNSH_skew_pred_bin], levels = unique(SKNSH_skew_pred_bin_map))) %>% 
	mutate(ENCODE_cCREs = factor(ENCODE_cCREs_map[ENCODE_cCREs], levels = unique(ENCODE_cCREs_map))) %>% 
	mutate(CADD_bin = factor(CADD_bin, levels = names(CADD_bin_map))) %>% 
	mutate(category = factor(category, levels = names(category_short_map)))

colSums(is.na(gnomAD_main_table))

saveRDS(gnomAD_main_table, "../../results/gnomAD_selection_preprocess/gnomAD_main_table.rds")

# fix emvar definition
emVar_bins <- c(" (-Inf, -1.5)", "[-1.5, -1.0)", "[-1.0, -0.5)", "[0.5, 1.0)", "[1.0, 1.5)", "[1.5, Inf)")
gnomAD_main_table <- gnomAD_main_table %>% 
	mutate(emVar_category = 
		ifelse(
			(K562_skew_pred_bin %in% emVar_bins) & (HepG2_skew_pred_bin %in% emVar_bins) & (SKNSH_skew_pred_bin %in% emVar_bins), "K562+SKNSH+HepG2", 
		ifelse (
			(K562_skew_pred_bin %in% emVar_bins) & (HepG2_skew_pred_bin %in% emVar_bins) & !(SKNSH_skew_pred_bin %in% emVar_bins), "K562+HepG2", 
		ifelse (
			(K562_skew_pred_bin %in% emVar_bins) & (SKNSH_skew_pred_bin %in% emVar_bins) & !(HepG2_skew_pred_bin %in% emVar_bins), "K562+SKNSH", 
		ifelse (
			(SKNSH_skew_pred_bin %in% emVar_bins) & (HepG2_skew_pred_bin %in% emVar_bins) & !(K562_skew_pred_bin %in% emVar_bins), "SKNSH+HepG2", 
		ifelse (
			(K562_skew_pred_bin %in% emVar_bins) & !(HepG2_skew_pred_bin %in% emVar_bins) & !(SKNSH_skew_pred_bin %in% emVar_bins), "K562", 
		ifelse (
			(HepG2_skew_pred_bin %in% emVar_bins) & !(K562_skew_pred_bin %in% emVar_bins) & !(SKNSH_skew_pred_bin %in% emVar_bins), "HepG2", 
		ifelse (
			(SKNSH_skew_pred_bin %in% emVar_bins) & !(K562_skew_pred_bin %in% emVar_bins) & !(HepG2_skew_pred_bin %in% emVar_bins), "SKNSH", 
			"none"
		)))))))
	) %>%  
	mutate(emVar_category = factor(emVar_category, levels = names(emVar_category_colors))) %>% 
	mutate(pleio = emVar_category_pleio[emVar_category])

saveRDS(gnomAD_main_table, "../../results/gnomAD_selection_preprocess/gnomAD_main_table.rds")

# # # 

# reload save
gnomAD_main_table <- readRDS("../../results/gnomAD_selection_preprocess/gnomAD_main_table.rds")

# get odds ratios
odds_helper <- function(gnomAD_main_table, cond_list=c(""), min_qc=50) {
	# gnomAD_main_table is always gnomAD_main_table from above
	# prefix is one of "mean", "K562", "HepG2", or "SKNSH"
	# cond_list is a c(), defaults to empty, could contain in_TF, in_rep, or emVar_category, or any combination
	# min_qc = minimum number of observations in bin to calculate statistics

	# collapse needed bins
	gnomAD_main_table_temp <- gnomAD_main_table %>% 
		dplyr::select(!!!sapply(cond_list, sym), count, category)

	# get category counts
	gnomAD_main_table_temp_p <- gnomAD_main_table_temp %>% 
		group_by(!!!sapply(cond_list, sym), category) %>% 
		summarise(
			count = sum(count)
		) %>% 
		mutate(category = factor(category, levels = names(category_short_map))) %>% arrange(category) %>% 
		pivot_wider(names_from = category, values_from = count, names_prefix = "long_") %>% 
		ungroup()

	# collapse counts in remapped bins
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		mutate(category = factor(category_short_map[category], levels = unique(category_short_map))) %>% arrange(category) %>% 
		group_by(!!!sapply(cond_list, sym), category) %>% 
		summarise(
			count = sum(count)
		) %>% 
		ungroup()

	# pivot wider rare and common counts
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>%
		arrange(!!!sapply(cond_list, sym), category) %>% 
		pivot_wider(names_from = category, values_from = count, names_prefix = "short_") %>% 
		mutate_at(c("short_RARE", "short_COMMON"), function(x) {ifelse(is.na(x), 0, x)}) %>% 
		mutate(count = short_RARE + short_COMMON) %>% 
		dplyr::select(!!!sapply(cond_list, sym), count, short_RARE, short_COMMON)

	# get genome baseline
	gnomAD_main_table_temp_gw <- colSums(gnomAD_main_table_temp[c("short_RARE", "short_COMMON")])

	# just reorganize odds
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>%
		arrange(!!!sapply(cond_list, sym))

	# compute fet
	# print(paste(prefix, cond_list, min_qc))
	wrapr::let(c(VAR1 = paste0("fet_RARE_COMMON"), VAR2 = paste0("fet_RARE_COMMON_pval"), VAR3 = paste0("fet_RARE_COMMON_odds"), VAR4 = paste0("fet_RARE_COMMON_lci"), VAR5 = paste0("fet_RARE_COMMON_uci"), VAR6 = paste0("fet_RARE_COMMON_padj"), VAR7 = paste0("fet_RARE_COMMON_sig")), 
		gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
			# filter(short_RARE + short_COMMON >= 50) %>% 
			rowwise() %>% 
			mutate(VAR1 = ifelse(short_RARE + short_COMMON >= min_qc, list(fisher.test(matrix(c(short_RARE+1, short_COMMON+1, gnomAD_main_table_temp_gw[["short_RARE"]]-short_RARE+1, gnomAD_main_table_temp_gw[["short_COMMON"]]-short_COMMON+1), nrow=2))), NA)) %>% 
			mutate(VAR2 = ifelse(short_RARE + short_COMMON >= min_qc, VAR1$p.val, NA)) %>% 
			mutate(VAR3 = ifelse(short_RARE + short_COMMON >= min_qc, VAR1$estimate, NA)) %>% 
			mutate(VAR4 = ifelse(short_RARE + short_COMMON >= min_qc, VAR1$conf.int[1], NA)) %>% 
			mutate(VAR5 = ifelse(short_RARE + short_COMMON >= min_qc, VAR1$conf.int[2], NA)) %>% 
			ungroup() %>% 
			mutate(VAR6 = p.adjust(VAR2, method = "fdr")) %>% 
			mutate(VAR7 = ifelse(VAR6 < 0.05, "*", ""))
	)

	# join category props
	# 	no min_qc, no CIs
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		full_join(gnomAD_main_table_temp_p) %>% 
		mutate(across(starts_with("long_"), 
			~ . / count, 
			.names = "long_prop_{sub('long_', '', .col)}")) %>% 
		mutate(across(starts_with("short_"), 
			~ . / count, 
			.names = "short_prop_{sub('short_', '', .col)}"))

	return(gnomAD_main_table_temp)
}

gnomAD_main_table_odds_ref <- gnomAD_main_table %>%
	odds_helper(c("mean_ref_pred_bin"))
gnomAD_main_table_odds_mean <- gnomAD_main_table %>%
	odds_helper(c("mean_skew_pred_bin"))

gnomAD_main_table_odds_cCREs <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs"))
gnomAD_main_table_odds_cCREs_in_TF <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "in_TF"))
gnomAD_main_table_odds_cCREs_in_rep <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "in_rep"))

gnomAD_main_table_odds_emVar_cat <- gnomAD_main_table %>%
	odds_helper(c("emVar_category"))
gnomAD_main_table_odds_cCREs_emVar_cat <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "emVar_category"))
gnomAD_main_table_odds_cCREs_pleio <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "pleio"))
gnomAD_main_table_odds_cCREs_pleio_mean <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "pleio", "mean_skew_pred_bin"))

gnomAD_main_table_odds_CADD <- gnomAD_main_table %>%
	odds_helper(c("CADD_bin"))
gnomAD_main_table_odds_cCREs_CADD <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "CADD_bin"))

gnomAD_main_table_odds_cCREs_mean <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "mean_skew_pred_bin"))
gnomAD_main_table_odds_cCREs_mean_in_TF <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "mean_skew_pred_bin", "in_TF"))
gnomAD_main_table_odds_cCREs_mean_in_rep <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "mean_skew_pred_bin", "in_rep"))

gnomAD_main_table_odds_cCREs_K562 <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "K562_skew_pred_bin"))
gnomAD_main_table_odds_cCREs_K562_in_TF <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "in_TF"))
gnomAD_main_table_odds_cCREs_K562_in_rep <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "in_rep"))

gnomAD_main_table_odds_cCREs_HepG2 <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin"))
gnomAD_main_table_odds_cCREs_HepG2_in_TF <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin", "in_TF"))
gnomAD_main_table_odds_cCREs_HepG2_in_rep <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin", "in_rep"))

gnomAD_main_table_odds_cCREs_SKNSH <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "SKNSH_skew_pred_bin"))
gnomAD_main_table_odds_cCREs_SKNSH_in_TF <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "SKNSH_skew_pred_bin", "in_TF"))
gnomAD_main_table_odds_cCREs_SKNSH_in_rep <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "SKNSH_skew_pred_bin", "in_rep"))

gnomAD_main_table_odds_cCREs_mean_ref <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "mean_ref_pred_bin"))
gnomAD_main_table_odds_cCREs_K562_ref <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "K562_ref_pred_bin"))
gnomAD_main_table_odds_cCREs_HepG2_ref <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "HepG2_ref_pred_bin"))
gnomAD_main_table_odds_cCREs_SKNSH_ref <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "SKNSH_ref_pred_bin"))

gnomAD_main_table_odds_in_TF_mean <- gnomAD_main_table %>%
	odds_helper(c("in_TF", "mean_skew_pred_bin"))
gnomAD_main_table_odds_in_TF_K562 <- gnomAD_main_table %>%
	odds_helper(c("in_TF", "K562_skew_pred_bin"))
gnomAD_main_table_odds_in_TF_HepG2 <- gnomAD_main_table %>%
	odds_helper(c("in_TF", "HepG2_skew_pred_bin"))
gnomAD_main_table_odds_in_TF_SKNSH <- gnomAD_main_table %>%
	odds_helper(c("in_TF", "SKNSH_skew_pred_bin"))

gnomAD_main_table_odds_in_TF_mean_ref <- gnomAD_main_table %>%
	odds_helper(c("in_TF", "mean_ref_pred_bin"))
gnomAD_main_table_odds_in_TF_K562_ref <- gnomAD_main_table %>%
	odds_helper(c("in_TF", "K562_ref_pred_bin"))
gnomAD_main_table_odds_in_TF_HepG2_ref <- gnomAD_main_table %>%
	odds_helper(c("in_TF", "HepG2_ref_pred_bin"))
gnomAD_main_table_odds_in_TF_SKNSH_ref <- gnomAD_main_table %>%
	odds_helper(c("in_TF", "SKNSH_ref_pred_bin"))

gnomAD_main_table_odds_in_rep_mean <- gnomAD_main_table %>%
	odds_helper(c("in_rep", "mean_skew_pred_bin"))
gnomAD_main_table_odds_in_rep_K562 <- gnomAD_main_table %>%
	odds_helper(c("in_rep", "K562_skew_pred_bin"))
gnomAD_main_table_odds_in_rep_HepG2 <- gnomAD_main_table %>%
	odds_helper(c("in_rep", "HepG2_skew_pred_bin"))
gnomAD_main_table_odds_in_rep_SKNSH <- gnomAD_main_table %>%
	odds_helper(c("in_rep", "SKNSH_skew_pred_bin"))

gnomAD_main_table_odds_in_rep_mean_ref <- gnomAD_main_table %>%
	odds_helper(c("in_rep", "mean_ref_pred_bin"))
gnomAD_main_table_odds_in_rep_K562_ref <- gnomAD_main_table %>%
	odds_helper(c("in_rep", "K562_ref_pred_bin"))
gnomAD_main_table_odds_in_rep_HepG2_ref <- gnomAD_main_table %>%
	odds_helper(c("in_rep", "HepG2_ref_pred_bin"))
gnomAD_main_table_odds_in_rep_SKNSH_ref <- gnomAD_main_table %>%
	odds_helper(c("in_rep", "SKNSH_ref_pred_bin"))

gnomAD_main_table_odds_cCREs_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	odds_helper(c("ENCODE_cCREs", "category_copy"))
gnomAD_main_table_odds_cCREs_mean_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	odds_helper(c("ENCODE_cCREs", "mean_skew_pred_bin", "category_copy"))
gnomAD_main_table_odds_cCREs_K562_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	odds_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "category_copy"))
gnomAD_main_table_odds_cCREs_HepG2_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	odds_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin", "category_copy"))
gnomAD_main_table_odds_cCREs_SKNSH_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	odds_helper(c("ENCODE_cCREs", "SKNSH_skew_pred_bin", "category_copy"))

gnomAD_main_table_odds_cCREs_mean_mean <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "mean_ref_pred_bin", "mean_skew_pred_bin"))
gnomAD_main_table_odds_cCREs_K562_K562 <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "K562_ref_pred_bin", "K562_skew_pred_bin"))
gnomAD_main_table_odds_cCREs_HepG2_HepG2 <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "HepG2_ref_pred_bin", "HepG2_skew_pred_bin"))
gnomAD_main_table_odds_cCREs_SKNSH_SKNSH <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "SKNSH_ref_pred_bin", "SKNSH_skew_pred_bin"))

gnomAD_main_table_odds_cCREs_emVar_cat_mean <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "emVar_category", "mean_skew_pred_bin"))
gnomAD_main_table_odds_cCREs_emVar_cat_K562 <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "emVar_category", "K562_skew_pred_bin"))
gnomAD_main_table_odds_cCREs_emVar_cat_HepG2 <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "emVar_category", "HepG2_skew_pred_bin"))
gnomAD_main_table_odds_cCREs_emVar_cat_SKNSH <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "emVar_category", "SKNSH_skew_pred_bin"))

gnomAD_main_table_odds_cCREs_K562_HepG2 <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "HepG2_skew_pred_bin"))
gnomAD_main_table_odds_cCREs_K562_SKNSH <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "SKNSH_skew_pred_bin"))
gnomAD_main_table_odds_cCREs_HepG2_SKNSH <- gnomAD_main_table %>%
	odds_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin", "SKNSH_skew_pred_bin"))

# get phyloP ratios
phyloP_helper <- function(gnomAD_main_table, cond_list=c(""), min_qc=50) {
	# gnomAD_main_table is always gnomAD_main_table from above
	# prefix is one of "mean", "K562", "HepG2", or "SKNSH"
	# cond_list is a c(), defaults to empty, could contain in_TF, in_rep, or emVar_category, or any combination
	# min_qc = minimum number of observations in bin to calculate statistics

	# collapse needed bins
	gnomAD_main_table_temp <- gnomAD_main_table %>% 
		dplyr::select(!!!sapply(cond_list, sym), count, sum_phylop, sum_of_squared_phylop, phylop_significant)

	# collapse counts in remapped bins
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		group_by(!!!sapply(cond_list, sym)) %>% 
		summarise(
			sum_of_phylop_significant = sum(phylop_significant*count),
			sum_of_squared_phylop = sum(sum_of_squared_phylop), 
			sum_phylop = sum(sum_phylop),
			count = sum(count), 
		) %>% 
		ungroup() %>% 
		dplyr::select(!!!sapply(cond_list, sym), count, sum_phylop, sum_of_squared_phylop, sum_of_phylop_significant)

	# just reorganize phyloP
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>%
		arrange(!!!sapply(cond_list, sym))

	# compute phyloP statistics
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		# filter(count >= min_qc) %>% 
		mutate(phyloP_mean = ifelse(count >= min_qc, (sum_phylop/count), NA)) %>% 
		mutate(phyloP_sd = ifelse(count >= min_qc, (sqrt((sum_of_squared_phylop - count*phyloP_mean**2)/(count-1))), NA)) %>% 
		mutate(phyloP_se = ifelse(count >= min_qc, (phyloP_sd/sqrt(count)), NA)) %>% 
		mutate(phyloP_lci = ifelse(count >= min_qc, (phyloP_mean - 2*phyloP_se), NA)) %>% 
		mutate(phyloP_uci = ifelse(count >= min_qc, (phyloP_mean + 2*phyloP_se), NA)) %>% 
		mutate(phyloP_stat = ifelse(count >= min_qc, ((phyloP_mean - 0)/phyloP_se), NA)) %>% 
		rowwise() %>% 
		mutate(phyloP_pval = ifelse(count >= min_qc, (2*pt(-abs(phyloP_stat), count-1, lower.tail = TRUE)), NA)) %>% 
		ungroup() %>% 
		mutate(phyloP_padj = p.adjust(phyloP_pval, method = "fdr")) %>% 
		mutate(phyloP_sig = ifelse(phyloP_padj < 0.05, "*", "")) 

	# compute phyloP cons statistics
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		mutate(
			phyloP_cons_prop = ifelse(count >= min_qc, sum_of_phylop_significant/count, NA)
		) %>% 
		mutate(
			phyloP_cons_prop_sd = ifelse(count >= min_qc, sqrt(phyloP_cons_prop*(1-phyloP_cons_prop)/count), NA)
		) %>% 
		mutate(
			phyloP_cons_prop_lci = ifelse(count >= min_qc, phyloP_cons_prop - 2*phyloP_cons_prop_sd, NA),
			phyloP_cons_prop_uci = ifelse(count >= min_qc, phyloP_cons_prop + 2*phyloP_cons_prop_sd, NA)
		)

	return(gnomAD_main_table_temp)
}

gnomAD_main_table_phyloP_ref <- gnomAD_main_table %>%
	phyloP_helper(c("mean_ref_pred_bin"))
gnomAD_main_table_phyloP_mean <- gnomAD_main_table %>%
	phyloP_helper(c("mean_skew_pred_bin"))

gnomAD_main_table_phyloP_cCREs <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs"))
gnomAD_main_table_phyloP_cCREs_in_TF <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "in_TF"))
gnomAD_main_table_phyloP_cCREs_in_rep <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "in_rep"))

gnomAD_main_table_phyloP_emVar_cat <- gnomAD_main_table %>%
	phyloP_helper(c("emVar_category"))
gnomAD_main_table_phyloP_cCREs_emVar_cat <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "emVar_category"))
gnomAD_main_table_phyloP_cCREs_pleio <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "pleio"))
gnomAD_main_table_phyloP_cCREs_pleio_mean <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "pleio", "mean_skew_pred_bin"))

gnomAD_main_table_phyloP_CADD <- gnomAD_main_table %>%
	phyloP_helper(c("CADD_bin"))
gnomAD_main_table_phyloP_cCREs_CADD <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "CADD_bin"))

gnomAD_main_table_phyloP_cCREs_mean <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "mean_skew_pred_bin"))
gnomAD_main_table_phyloP_cCREs_mean_in_TF <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "mean_skew_pred_bin", "in_TF"))
gnomAD_main_table_phyloP_cCREs_mean_in_rep <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "mean_skew_pred_bin", "in_rep"))

gnomAD_main_table_phyloP_cCREs_K562 <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "K562_skew_pred_bin"))
gnomAD_main_table_phyloP_cCREs_K562_in_TF <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "in_TF"))
gnomAD_main_table_phyloP_cCREs_K562_in_rep <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "in_rep"))

gnomAD_main_table_phyloP_cCREs_HepG2 <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin"))
gnomAD_main_table_phyloP_cCREs_HepG2_in_TF <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin", "in_TF"))
gnomAD_main_table_phyloP_cCREs_HepG2_in_rep <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin", "in_rep"))

gnomAD_main_table_phyloP_cCREs_SKNSH <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "SKNSH_skew_pred_bin"))
gnomAD_main_table_phyloP_cCREs_SKNSH_in_TF <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "SKNSH_skew_pred_bin", "in_TF"))
gnomAD_main_table_phyloP_cCREs_SKNSH_in_rep <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "SKNSH_skew_pred_bin", "in_rep"))

gnomAD_main_table_phyloP_cCREs_mean_ref <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "mean_ref_pred_bin"))
gnomAD_main_table_phyloP_cCREs_K562_ref <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "K562_ref_pred_bin"))
gnomAD_main_table_phyloP_cCREs_HepG2_ref <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "HepG2_ref_pred_bin"))
gnomAD_main_table_phyloP_cCREs_SKNSH_ref <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "SKNSH_ref_pred_bin"))

gnomAD_main_table_phyloP_in_TF_mean <- gnomAD_main_table %>%
	phyloP_helper(c("in_TF", "mean_skew_pred_bin"))
gnomAD_main_table_phyloP_in_TF_K562 <- gnomAD_main_table %>%
	phyloP_helper(c("in_TF", "K562_skew_pred_bin"))
gnomAD_main_table_phyloP_in_TF_HepG2 <- gnomAD_main_table %>%
	phyloP_helper(c("in_TF", "HepG2_skew_pred_bin"))
gnomAD_main_table_phyloP_in_TF_SKNSH <- gnomAD_main_table %>%
	phyloP_helper(c("in_TF", "SKNSH_skew_pred_bin"))

gnomAD_main_table_phyloP_in_TF_mean_ref <- gnomAD_main_table %>%
	phyloP_helper(c("in_TF", "mean_ref_pred_bin"))
gnomAD_main_table_phyloP_in_TF_K562_ref <- gnomAD_main_table %>%
	phyloP_helper(c("in_TF", "K562_ref_pred_bin"))
gnomAD_main_table_phyloP_in_TF_HepG2_ref <- gnomAD_main_table %>%
	phyloP_helper(c("in_TF", "HepG2_ref_pred_bin"))
gnomAD_main_table_phyloP_in_TF_SKNSH_ref <- gnomAD_main_table %>%
	phyloP_helper(c("in_TF", "SKNSH_ref_pred_bin"))

gnomAD_main_table_phyloP_in_rep_mean <- gnomAD_main_table %>%
	phyloP_helper(c("in_rep", "mean_skew_pred_bin"))
gnomAD_main_table_phyloP_in_rep_K562 <- gnomAD_main_table %>%
	phyloP_helper(c("in_rep", "K562_skew_pred_bin"))
gnomAD_main_table_phyloP_in_rep_HepG2 <- gnomAD_main_table %>%
	phyloP_helper(c("in_rep", "HepG2_skew_pred_bin"))
gnomAD_main_table_phyloP_in_rep_SKNSH <- gnomAD_main_table %>%
	phyloP_helper(c("in_rep", "SKNSH_skew_pred_bin"))

gnomAD_main_table_phyloP_in_rep_mean_ref <- gnomAD_main_table %>%
	phyloP_helper(c("in_rep", "mean_ref_pred_bin"))
gnomAD_main_table_phyloP_in_rep_K562_ref <- gnomAD_main_table %>%
	phyloP_helper(c("in_rep", "K562_ref_pred_bin"))
gnomAD_main_table_phyloP_in_rep_HepG2_ref <- gnomAD_main_table %>%
	phyloP_helper(c("in_rep", "HepG2_ref_pred_bin"))
gnomAD_main_table_phyloP_in_rep_SKNSH_ref <- gnomAD_main_table %>%
	phyloP_helper(c("in_rep", "SKNSH_ref_pred_bin"))

gnomAD_main_table_phyloP_cCREs_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	phyloP_helper(c("ENCODE_cCREs", "category_copy"))
gnomAD_main_table_phyloP_cCREs_mean_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	phyloP_helper(c("ENCODE_cCREs", "mean_skew_pred_bin", "category_copy"))
gnomAD_main_table_phyloP_cCREs_K562_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	phyloP_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "category_copy"))
gnomAD_main_table_phyloP_cCREs_HepG2_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	phyloP_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin", "category_copy"))
gnomAD_main_table_phyloP_cCREs_SKNSH_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	phyloP_helper(c("ENCODE_cCREs", "SKNSH_skew_pred_bin", "category_copy"))

gnomAD_main_table_phyloP_cCREs_mean_mean <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "mean_ref_pred_bin", "mean_skew_pred_bin"))
gnomAD_main_table_phyloP_cCREs_K562_K562 <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "K562_ref_pred_bin", "K562_skew_pred_bin"))
gnomAD_main_table_phyloP_cCREs_HepG2_HepG2 <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "HepG2_ref_pred_bin", "HepG2_skew_pred_bin"))
gnomAD_main_table_phyloP_cCREs_SKNSH_SKNSH <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "SKNSH_ref_pred_bin", "SKNSH_skew_pred_bin"))

gnomAD_main_table_phyloP_cCREs_emVar_cat_mean <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "emVar_category", "mean_skew_pred_bin"))
gnomAD_main_table_phyloP_cCREs_emVar_cat_K562 <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "emVar_category", "K562_skew_pred_bin"))
gnomAD_main_table_phyloP_cCREs_emVar_cat_HepG2 <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "emVar_category", "HepG2_skew_pred_bin"))
gnomAD_main_table_phyloP_cCREs_emVar_cat_SKNSH <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "emVar_category", "SKNSH_skew_pred_bin"))

gnomAD_main_table_phyloP_cCREs_K562_HepG2 <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "HepG2_skew_pred_bin"))
gnomAD_main_table_phyloP_cCREs_K562_SKNSH <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "SKNSH_skew_pred_bin"))
gnomAD_main_table_phyloP_cCREs_HepG2_SKNSH <- gnomAD_main_table %>%
	phyloP_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin", "SKNSH_skew_pred_bin"))

# get mutrate ratios
mutrate_helper <- function(gnomAD_main_table, cond_list=c(""), min_qc=50) {
	# gnomAD_main_table is always gnomAD_main_table from above
	# prefix is one of "mean", "K562", "HepG2", or "SKNSH"
	# cond_list is a c(), defaults to empty, could contain in_TF, in_rep, or emVar_category, or any combination
	# min_qc = minimum number of observations in bin to calculate statistics

	# collapse needed bins
	gnomAD_main_table_temp <- gnomAD_main_table %>% 
		dplyr::select(!!!sapply(cond_list, sym), count, sum_roulette_MR, sum_of_squared_roulette_MR)

	# collapse counts in remapped bins
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		group_by(!!!sapply(cond_list, sym)) %>% 
		summarise(
			count = sum(count), 
			sum_roulette_MR = sum(sum_roulette_MR),
			sum_of_squared_roulette_MR = sum(sum_of_squared_roulette_MR)
		) %>% 
		ungroup()

	# just reorganize mutrate
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>%
		arrange(!!!sapply(cond_list, sym))

	# compute mutrate statistics
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		# filter(count >= min_qc) %>% 
		mutate(mutrate_mean = ifelse(count >= min_qc, (sum_roulette_MR/count), NA)) %>% 
		mutate(mutrate_sd = ifelse(count >= min_qc, (sqrt((sum_of_squared_roulette_MR - count*mutrate_mean**2)/(count-1))), NA)) %>% 
		mutate(mutrate_se = ifelse(count >= min_qc, (mutrate_sd/sqrt(count)), NA)) %>% 
		mutate(mutrate_lci = ifelse(count >= min_qc, (mutrate_mean - 2*mutrate_se), NA)) %>% 
		mutate(mutrate_uci = ifelse(count >= min_qc, (mutrate_mean + 2*mutrate_se), NA)) %>% 
		mutate(mutrate_stat = ifelse(count >= min_qc, ((mutrate_mean - 0)/mutrate_se), NA)) %>% 
		rowwise() %>% 
		mutate(mutrate_pval = ifelse(count >= min_qc, (2*pt(-abs(mutrate_stat), count-1, lower.tail = TRUE)), NA)) %>% 
		ungroup() %>% 
		mutate(mutrate_padj = p.adjust(mutrate_pval, method = "fdr")) %>% 
		mutate(mutrate_sig = ifelse(mutrate_padj < 0.05, "*", "")) 

	return(gnomAD_main_table_temp)
}

gnomAD_main_table_mutrate_ref <- gnomAD_main_table %>%
	mutrate_helper(c("mean_ref_pred_bin"))
gnomAD_main_table_mutrate_mean <- gnomAD_main_table %>%
	mutrate_helper(c("mean_skew_pred_bin"))

gnomAD_main_table_mutrate_cCREs <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs"))
gnomAD_main_table_mutrate_cCREs_in_TF <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "in_TF"))
gnomAD_main_table_mutrate_cCREs_in_rep <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "in_rep"))

gnomAD_main_table_mutrate_emVar_cat <- gnomAD_main_table %>%
	mutrate_helper(c("emVar_category"))
gnomAD_main_table_mutrate_cCREs_emVar_cat <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "emVar_category"))
gnomAD_main_table_mutrate_cCREs_pleio <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "pleio"))
gnomAD_main_table_mutrate_cCREs_pleio_mean <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "pleio", "mean_skew_pred_bin"))

gnomAD_main_table_mutrate_CADD <- gnomAD_main_table %>%
	mutrate_helper(c("CADD_bin"))
gnomAD_main_table_mutrate_cCREs_CADD <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "CADD_bin"))

gnomAD_main_table_mutrate_cCREs_mean <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "mean_skew_pred_bin"))
gnomAD_main_table_mutrate_cCREs_mean_in_TF <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "mean_skew_pred_bin", "in_TF"))
gnomAD_main_table_mutrate_cCREs_mean_in_rep <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "mean_skew_pred_bin", "in_rep"))

gnomAD_main_table_mutrate_cCREs_K562 <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "K562_skew_pred_bin"))
gnomAD_main_table_mutrate_cCREs_K562_in_TF <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "in_TF"))
gnomAD_main_table_mutrate_cCREs_K562_in_rep <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "in_rep"))

gnomAD_main_table_mutrate_cCREs_HepG2 <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin"))
gnomAD_main_table_mutrate_cCREs_HepG2_in_TF <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin", "in_TF"))
gnomAD_main_table_mutrate_cCREs_HepG2_in_rep <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin", "in_rep"))

gnomAD_main_table_mutrate_cCREs_SKNSH <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "SKNSH_skew_pred_bin"))
gnomAD_main_table_mutrate_cCREs_SKNSH_in_TF <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "SKNSH_skew_pred_bin", "in_TF"))
gnomAD_main_table_mutrate_cCREs_SKNSH_in_rep <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "SKNSH_skew_pred_bin", "in_rep"))

gnomAD_main_table_mutrate_cCREs_mean_ref <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "mean_ref_pred_bin"))
gnomAD_main_table_mutrate_cCREs_K562_ref <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "K562_ref_pred_bin"))
gnomAD_main_table_mutrate_cCREs_HepG2_ref <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "HepG2_ref_pred_bin"))
gnomAD_main_table_mutrate_cCREs_SKNSH_ref <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "SKNSH_ref_pred_bin"))

gnomAD_main_table_mutrate_in_TF_mean <- gnomAD_main_table %>%
	mutrate_helper(c("in_TF", "mean_skew_pred_bin"))
gnomAD_main_table_mutrate_in_TF_K562 <- gnomAD_main_table %>%
	mutrate_helper(c("in_TF", "K562_skew_pred_bin"))
gnomAD_main_table_mutrate_in_TF_HepG2 <- gnomAD_main_table %>%
	mutrate_helper(c("in_TF", "HepG2_skew_pred_bin"))
gnomAD_main_table_mutrate_in_TF_SKNSH <- gnomAD_main_table %>%
	mutrate_helper(c("in_TF", "SKNSH_skew_pred_bin"))

gnomAD_main_table_mutrate_in_TF_mean_ref <- gnomAD_main_table %>%
	mutrate_helper(c("in_TF", "mean_ref_pred_bin"))
gnomAD_main_table_mutrate_in_TF_K562_ref <- gnomAD_main_table %>%
	mutrate_helper(c("in_TF", "K562_ref_pred_bin"))
gnomAD_main_table_mutrate_in_TF_HepG2_ref <- gnomAD_main_table %>%
	mutrate_helper(c("in_TF", "HepG2_ref_pred_bin"))
gnomAD_main_table_mutrate_in_TF_SKNSH_ref <- gnomAD_main_table %>%
	mutrate_helper(c("in_TF", "SKNSH_ref_pred_bin"))

gnomAD_main_table_mutrate_in_rep_mean <- gnomAD_main_table %>%
	mutrate_helper(c("in_rep", "mean_skew_pred_bin"))
gnomAD_main_table_mutrate_in_rep_K562 <- gnomAD_main_table %>%
	mutrate_helper(c("in_rep", "K562_skew_pred_bin"))
gnomAD_main_table_mutrate_in_rep_HepG2 <- gnomAD_main_table %>%
	mutrate_helper(c("in_rep", "HepG2_skew_pred_bin"))
gnomAD_main_table_mutrate_in_rep_SKNSH <- gnomAD_main_table %>%
	mutrate_helper(c("in_rep", "SKNSH_skew_pred_bin"))

gnomAD_main_table_mutrate_in_rep_mean_ref <- gnomAD_main_table %>%
	mutrate_helper(c("in_rep", "mean_ref_pred_bin"))
gnomAD_main_table_mutrate_in_rep_K562_ref <- gnomAD_main_table %>%
	mutrate_helper(c("in_rep", "K562_ref_pred_bin"))
gnomAD_main_table_mutrate_in_rep_HepG2_ref <- gnomAD_main_table %>%
	mutrate_helper(c("in_rep", "HepG2_ref_pred_bin"))
gnomAD_main_table_mutrate_in_rep_SKNSH_ref <- gnomAD_main_table %>%
	mutrate_helper(c("in_rep", "SKNSH_ref_pred_bin"))

gnomAD_main_table_mutrate_cCREs_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	mutrate_helper(c("ENCODE_cCREs", "category_copy"))
gnomAD_main_table_mutrate_cCREs_mean_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	mutrate_helper(c("ENCODE_cCREs", "mean_skew_pred_bin", "category_copy"))
gnomAD_main_table_mutrate_cCREs_K562_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	mutrate_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "category_copy"))
gnomAD_main_table_mutrate_cCREs_HepG2_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	mutrate_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin", "category_copy"))
gnomAD_main_table_mutrate_cCREs_SKNSH_category <- gnomAD_main_table %>% 
	mutate(category_copy = category) %>% 
	mutrate_helper(c("ENCODE_cCREs", "SKNSH_skew_pred_bin", "category_copy"))

gnomAD_main_table_mutrate_cCREs_mean_mean <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "mean_ref_pred_bin", "mean_skew_pred_bin"))
gnomAD_main_table_mutrate_cCREs_K562_K562 <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "K562_ref_pred_bin", "K562_skew_pred_bin"))
gnomAD_main_table_mutrate_cCREs_HepG2_HepG2 <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "HepG2_ref_pred_bin", "HepG2_skew_pred_bin"))
gnomAD_main_table_mutrate_cCREs_SKNSH_SKNSH <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "SKNSH_ref_pred_bin", "SKNSH_skew_pred_bin"))

gnomAD_main_table_mutrate_cCREs_emVar_cat_mean <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "emVar_category", "mean_skew_pred_bin"))
gnomAD_main_table_mutrate_cCREs_emVar_cat_K562 <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "emVar_category", "K562_skew_pred_bin"))
gnomAD_main_table_mutrate_cCREs_emVar_cat_HepG2 <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "emVar_category", "HepG2_skew_pred_bin"))
gnomAD_main_table_mutrate_cCREs_emVar_cat_SKNSH <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "emVar_category", "SKNSH_skew_pred_bin"))

gnomAD_main_table_mutrate_cCREs_K562_HepG2 <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "HepG2_skew_pred_bin"))
gnomAD_main_table_mutrate_cCREs_K562_SKNSH <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "K562_skew_pred_bin", "SKNSH_skew_pred_bin"))
gnomAD_main_table_mutrate_cCREs_HepG2_SKNSH <- gnomAD_main_table %>%
	mutrate_helper(c("ENCODE_cCREs", "HepG2_skew_pred_bin", "SKNSH_skew_pred_bin"))

# do full joins
gnomAD_main_table_full_ref <- gnomAD_main_table_odds_ref %>% full_join(gnomAD_main_table_phyloP_ref) %>% full_join(gnomAD_main_table_mutrate_ref)
gnomAD_main_table_full_mean <- gnomAD_main_table_odds_mean %>% full_join(gnomAD_main_table_phyloP_mean) %>% full_join(gnomAD_main_table_mutrate_mean)
gnomAD_main_table_full_cCREs <- gnomAD_main_table_odds_cCREs %>% full_join(gnomAD_main_table_phyloP_cCREs) %>% full_join(gnomAD_main_table_mutrate_cCREs)
gnomAD_main_table_full_cCREs_in_TF <- gnomAD_main_table_odds_cCREs_in_TF %>% full_join(gnomAD_main_table_phyloP_cCREs_in_TF) %>% full_join(gnomAD_main_table_mutrate_cCREs_in_TF)
gnomAD_main_table_full_cCREs_in_rep <- gnomAD_main_table_odds_cCREs_in_rep %>% full_join(gnomAD_main_table_phyloP_cCREs_in_rep) %>% full_join(gnomAD_main_table_mutrate_cCREs_in_rep)
gnomAD_main_table_full_emVar_cat <- gnomAD_main_table_odds_emVar_cat %>% full_join(gnomAD_main_table_phyloP_emVar_cat) %>% full_join(gnomAD_main_table_mutrate_emVar_cat)
gnomAD_main_table_full_cCREs_emVar_cat <- gnomAD_main_table_odds_cCREs_emVar_cat %>% full_join(gnomAD_main_table_phyloP_cCREs_emVar_cat) %>% full_join(gnomAD_main_table_mutrate_cCREs_emVar_cat)
gnomAD_main_table_full_cCREs_pleio <- gnomAD_main_table_odds_cCREs_pleio %>% full_join(gnomAD_main_table_phyloP_cCREs_pleio) %>% full_join(gnomAD_main_table_mutrate_cCREs_pleio)
gnomAD_main_table_full_cCREs_pleio_mean <- gnomAD_main_table_odds_cCREs_pleio_mean %>% full_join(gnomAD_main_table_phyloP_cCREs_pleio_mean) %>% full_join(gnomAD_main_table_mutrate_cCREs_pleio_mean)
gnomAD_main_table_full_CADD <- gnomAD_main_table_odds_CADD %>% full_join(gnomAD_main_table_phyloP_CADD) %>% full_join(gnomAD_main_table_mutrate_CADD)
gnomAD_main_table_full_cCREs_CADD <- gnomAD_main_table_odds_cCREs_CADD %>% full_join(gnomAD_main_table_phyloP_cCREs_CADD) %>% full_join(gnomAD_main_table_mutrate_cCREs_CADD)
gnomAD_main_table_full_cCREs_mean <- gnomAD_main_table_odds_cCREs_mean %>% full_join(gnomAD_main_table_phyloP_cCREs_mean) %>% full_join(gnomAD_main_table_mutrate_cCREs_mean)
gnomAD_main_table_full_cCREs_mean_in_TF <- gnomAD_main_table_odds_cCREs_mean_in_TF %>% full_join(gnomAD_main_table_phyloP_cCREs_mean_in_TF) %>% full_join(gnomAD_main_table_mutrate_cCREs_mean_in_TF)
gnomAD_main_table_full_cCREs_mean_in_rep <- gnomAD_main_table_odds_cCREs_mean_in_rep %>% full_join(gnomAD_main_table_phyloP_cCREs_mean_in_rep) %>% full_join(gnomAD_main_table_mutrate_cCREs_mean_in_rep)
gnomAD_main_table_full_cCREs_K562 <- gnomAD_main_table_odds_cCREs_K562 %>% full_join(gnomAD_main_table_phyloP_cCREs_K562) %>% full_join(gnomAD_main_table_mutrate_cCREs_K562)
gnomAD_main_table_full_cCREs_K562_in_TF <- gnomAD_main_table_odds_cCREs_K562_in_TF %>% full_join(gnomAD_main_table_phyloP_cCREs_K562_in_TF) %>% full_join(gnomAD_main_table_mutrate_cCREs_K562_in_TF)
gnomAD_main_table_full_cCREs_K562_in_rep <- gnomAD_main_table_odds_cCREs_K562_in_rep %>% full_join(gnomAD_main_table_phyloP_cCREs_K562_in_rep) %>% full_join(gnomAD_main_table_mutrate_cCREs_K562_in_rep)
gnomAD_main_table_full_cCREs_HepG2 <- gnomAD_main_table_odds_cCREs_HepG2 %>% full_join(gnomAD_main_table_phyloP_cCREs_HepG2) %>% full_join(gnomAD_main_table_mutrate_cCREs_HepG2)
gnomAD_main_table_full_cCREs_HepG2_in_TF <- gnomAD_main_table_odds_cCREs_HepG2_in_TF %>% full_join(gnomAD_main_table_phyloP_cCREs_HepG2_in_TF) %>% full_join(gnomAD_main_table_mutrate_cCREs_HepG2_in_TF)
gnomAD_main_table_full_cCREs_HepG2_in_rep <- gnomAD_main_table_odds_cCREs_HepG2_in_rep %>% full_join(gnomAD_main_table_phyloP_cCREs_HepG2_in_rep) %>% full_join(gnomAD_main_table_mutrate_cCREs_HepG2_in_rep)
gnomAD_main_table_full_cCREs_SKNSH <- gnomAD_main_table_odds_cCREs_SKNSH %>% full_join(gnomAD_main_table_phyloP_cCREs_SKNSH) %>% full_join(gnomAD_main_table_mutrate_cCREs_SKNSH)
gnomAD_main_table_full_cCREs_SKNSH_in_TF <- gnomAD_main_table_odds_cCREs_SKNSH_in_TF %>% full_join(gnomAD_main_table_phyloP_cCREs_SKNSH_in_TF) %>% full_join(gnomAD_main_table_mutrate_cCREs_SKNSH_in_TF)
gnomAD_main_table_full_cCREs_SKNSH_in_rep <- gnomAD_main_table_odds_cCREs_SKNSH_in_rep %>% full_join(gnomAD_main_table_phyloP_cCREs_SKNSH_in_rep) %>% full_join(gnomAD_main_table_mutrate_cCREs_SKNSH_in_rep)
gnomAD_main_table_full_cCREs_mean_ref <- gnomAD_main_table_odds_cCREs_mean_ref %>% full_join(gnomAD_main_table_phyloP_cCREs_mean_ref) %>% full_join(gnomAD_main_table_mutrate_cCREs_mean_ref)
gnomAD_main_table_full_cCREs_K562_ref <- gnomAD_main_table_odds_cCREs_K562_ref %>% full_join(gnomAD_main_table_phyloP_cCREs_K562_ref) %>% full_join(gnomAD_main_table_mutrate_cCREs_K562_ref)
gnomAD_main_table_full_cCREs_HepG2_ref <- gnomAD_main_table_odds_cCREs_HepG2_ref %>% full_join(gnomAD_main_table_phyloP_cCREs_HepG2_ref) %>% full_join(gnomAD_main_table_mutrate_cCREs_HepG2_ref)
gnomAD_main_table_full_cCREs_SKNSH_ref <- gnomAD_main_table_odds_cCREs_SKNSH_ref %>% full_join(gnomAD_main_table_phyloP_cCREs_SKNSH_ref) %>% full_join(gnomAD_main_table_mutrate_cCREs_SKNSH_ref)
gnomAD_main_table_full_in_TF_mean <- gnomAD_main_table_odds_in_TF_mean %>% full_join(gnomAD_main_table_phyloP_in_TF_mean) %>% full_join(gnomAD_main_table_mutrate_in_TF_mean)
gnomAD_main_table_full_in_TF_K562 <- gnomAD_main_table_odds_in_TF_K562 %>% full_join(gnomAD_main_table_phyloP_in_TF_K562) %>% full_join(gnomAD_main_table_mutrate_in_TF_K562)
gnomAD_main_table_full_in_TF_HepG2 <- gnomAD_main_table_odds_in_TF_HepG2 %>% full_join(gnomAD_main_table_phyloP_in_TF_HepG2) %>% full_join(gnomAD_main_table_mutrate_in_TF_HepG2)
gnomAD_main_table_full_in_TF_SKNSH <- gnomAD_main_table_odds_in_TF_SKNSH %>% full_join(gnomAD_main_table_phyloP_in_TF_SKNSH) %>% full_join(gnomAD_main_table_mutrate_in_TF_SKNSH)
gnomAD_main_table_full_in_TF_mean_ref <- gnomAD_main_table_odds_in_TF_mean_ref %>% full_join(gnomAD_main_table_phyloP_in_TF_mean_ref) %>% full_join(gnomAD_main_table_mutrate_in_TF_mean_ref)
gnomAD_main_table_full_in_TF_K562_ref <- gnomAD_main_table_odds_in_TF_K562_ref %>% full_join(gnomAD_main_table_phyloP_in_TF_K562_ref) %>% full_join(gnomAD_main_table_mutrate_in_TF_K562_ref)
gnomAD_main_table_full_in_TF_HepG2_ref <- gnomAD_main_table_odds_in_TF_HepG2_ref %>% full_join(gnomAD_main_table_phyloP_in_TF_HepG2_ref) %>% full_join(gnomAD_main_table_mutrate_in_TF_HepG2_ref)
gnomAD_main_table_full_in_TF_SKNSH_ref <- gnomAD_main_table_odds_in_TF_SKNSH_ref %>% full_join(gnomAD_main_table_phyloP_in_TF_SKNSH_ref) %>% full_join(gnomAD_main_table_mutrate_in_TF_SKNSH_ref)
gnomAD_main_table_full_in_rep_mean <- gnomAD_main_table_odds_in_rep_mean %>% full_join(gnomAD_main_table_phyloP_in_rep_mean) %>% full_join(gnomAD_main_table_mutrate_in_rep_mean)
gnomAD_main_table_full_in_rep_K562 <- gnomAD_main_table_odds_in_rep_K562 %>% full_join(gnomAD_main_table_phyloP_in_rep_K562) %>% full_join(gnomAD_main_table_mutrate_in_rep_K562)
gnomAD_main_table_full_in_rep_HepG2 <- gnomAD_main_table_odds_in_rep_HepG2 %>% full_join(gnomAD_main_table_phyloP_in_rep_HepG2) %>% full_join(gnomAD_main_table_mutrate_in_rep_HepG2)
gnomAD_main_table_full_in_rep_SKNSH <- gnomAD_main_table_odds_in_rep_SKNSH %>% full_join(gnomAD_main_table_phyloP_in_rep_SKNSH) %>% full_join(gnomAD_main_table_mutrate_in_rep_SKNSH)
gnomAD_main_table_full_in_rep_mean_ref <- gnomAD_main_table_odds_in_rep_mean_ref %>% full_join(gnomAD_main_table_phyloP_in_rep_mean_ref) %>% full_join(gnomAD_main_table_mutrate_in_rep_mean_ref)
gnomAD_main_table_full_in_rep_K562_ref <- gnomAD_main_table_odds_in_rep_K562_ref %>% full_join(gnomAD_main_table_phyloP_in_rep_K562_ref) %>% full_join(gnomAD_main_table_mutrate_in_rep_K562_ref)
gnomAD_main_table_full_in_rep_HepG2_ref <- gnomAD_main_table_odds_in_rep_HepG2_ref %>% full_join(gnomAD_main_table_phyloP_in_rep_HepG2_ref) %>% full_join(gnomAD_main_table_mutrate_in_rep_HepG2_ref)
gnomAD_main_table_full_in_rep_SKNSH_ref <- gnomAD_main_table_odds_in_rep_SKNSH_ref %>% full_join(gnomAD_main_table_phyloP_in_rep_SKNSH_ref) %>% full_join(gnomAD_main_table_mutrate_in_rep_SKNSH_ref)
gnomAD_main_table_full_cCREs_mean_category <- gnomAD_main_table_odds_cCREs_mean_category %>% full_join(gnomAD_main_table_phyloP_cCREs_mean_category) %>% full_join(gnomAD_main_table_mutrate_cCREs_mean_category)
gnomAD_main_table_full_cCREs_category <- gnomAD_main_table_odds_cCREs_category %>% full_join(gnomAD_main_table_phyloP_cCREs_category) %>% full_join(gnomAD_main_table_mutrate_cCREs_category)
gnomAD_main_table_full_cCREs_K562_category <- gnomAD_main_table_odds_cCREs_K562_category %>% full_join(gnomAD_main_table_phyloP_cCREs_K562_category) %>% full_join(gnomAD_main_table_mutrate_cCREs_K562_category)
gnomAD_main_table_full_cCREs_HepG2_category <- gnomAD_main_table_odds_cCREs_HepG2_category %>% full_join(gnomAD_main_table_phyloP_cCREs_HepG2_category) %>% full_join(gnomAD_main_table_mutrate_cCREs_HepG2_category)
gnomAD_main_table_full_cCREs_SKNSH_category <- gnomAD_main_table_odds_cCREs_SKNSH_category %>% full_join(gnomAD_main_table_phyloP_cCREs_SKNSH_category) %>% full_join(gnomAD_main_table_mutrate_cCREs_SKNSH_category)
gnomAD_main_table_full_cCREs_mean_mean <- gnomAD_main_table_odds_cCREs_mean_mean %>% full_join(gnomAD_main_table_phyloP_cCREs_mean_mean) %>% full_join(gnomAD_main_table_mutrate_cCREs_mean_mean)
gnomAD_main_table_full_cCREs_K562_K562 <- gnomAD_main_table_odds_cCREs_K562_K562 %>% full_join(gnomAD_main_table_phyloP_cCREs_K562_K562) %>% full_join(gnomAD_main_table_mutrate_cCREs_K562_K562)
gnomAD_main_table_full_cCREs_HepG2_HepG2 <- gnomAD_main_table_odds_cCREs_HepG2_HepG2 %>% full_join(gnomAD_main_table_phyloP_cCREs_HepG2_HepG2) %>% full_join(gnomAD_main_table_mutrate_cCREs_HepG2_HepG2)
gnomAD_main_table_full_cCREs_SKNSH_SKNSH <- gnomAD_main_table_odds_cCREs_SKNSH_SKNSH %>% full_join(gnomAD_main_table_phyloP_cCREs_SKNSH_SKNSH) %>% full_join(gnomAD_main_table_mutrate_cCREs_SKNSH_SKNSH)
gnomAD_main_table_full_cCREs_emVar_cat_mean <- gnomAD_main_table_odds_cCREs_emVar_cat_mean %>% full_join(gnomAD_main_table_phyloP_cCREs_emVar_cat_mean) %>% full_join(gnomAD_main_table_mutrate_cCREs_emVar_cat_mean)
gnomAD_main_table_full_cCREs_emVar_cat_K562 <- gnomAD_main_table_odds_cCREs_emVar_cat_K562 %>% full_join(gnomAD_main_table_phyloP_cCREs_emVar_cat_K562) %>% full_join(gnomAD_main_table_mutrate_cCREs_emVar_cat_K562)
gnomAD_main_table_full_cCREs_emVar_cat_HepG2 <- gnomAD_main_table_odds_cCREs_emVar_cat_HepG2 %>% full_join(gnomAD_main_table_phyloP_cCREs_emVar_cat_HepG2) %>% full_join(gnomAD_main_table_mutrate_cCREs_emVar_cat_HepG2)
gnomAD_main_table_full_cCREs_emVar_cat_SKNSH <- gnomAD_main_table_odds_cCREs_emVar_cat_SKNSH %>% full_join(gnomAD_main_table_phyloP_cCREs_emVar_cat_SKNSH) %>% full_join(gnomAD_main_table_mutrate_cCREs_emVar_cat_SKNSH)
gnomAD_main_table_full_cCREs_K562_HepG2 <- gnomAD_main_table_odds_cCREs_K562_HepG2 %>% full_join(gnomAD_main_table_phyloP_cCREs_K562_HepG2) %>% full_join(gnomAD_main_table_mutrate_cCREs_K562_HepG2)
gnomAD_main_table_full_cCREs_K562_SKNSH <- gnomAD_main_table_odds_cCREs_K562_SKNSH %>% full_join(gnomAD_main_table_phyloP_cCREs_K562_SKNSH) %>% full_join(gnomAD_main_table_mutrate_cCREs_K562_SKNSH)
gnomAD_main_table_full_cCREs_HepG2_SKNSH <- gnomAD_main_table_odds_cCREs_HepG2_SKNSH %>% full_join(gnomAD_main_table_phyloP_cCREs_HepG2_SKNSH) %>% full_join(gnomAD_main_table_mutrate_cCREs_HepG2_SKNSH)

# save table and rds
saveRDS(gnomAD_main_table_full_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_ref.rds")
write_tsv(gnomAD_main_table_full_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_ref.tsv.gz"))
saveRDS(gnomAD_main_table_full_mean, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_mean.rds")
write_tsv(gnomAD_main_table_full_mean, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_mean.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs.rds")
write_tsv(gnomAD_main_table_full_cCREs, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_in_TF, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_in_TF.rds")
write_tsv(gnomAD_main_table_full_cCREs_in_TF, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_in_TF.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_in_rep, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_in_rep.rds")
write_tsv(gnomAD_main_table_full_cCREs_in_rep, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_in_rep.tsv.gz"))
saveRDS(gnomAD_main_table_full_emVar_cat, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_emVar_cat.rds")
write_tsv(gnomAD_main_table_full_emVar_cat, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_emVar_cat.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_emVar_cat, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_emVar_cat.rds")
write_tsv(gnomAD_main_table_full_cCREs_emVar_cat, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_emVar_cat.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_pleio, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_pleio.rds")
write_tsv(gnomAD_main_table_full_cCREs_pleio, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_pleio.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_pleio_mean, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_pleio_mean.rds")
write_tsv(gnomAD_main_table_full_cCREs_pleio_mean, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_pleio_mean.tsv.gz"))
saveRDS(gnomAD_main_table_full_CADD, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_CADD.rds")
write_tsv(gnomAD_main_table_full_CADD, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_CADD.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_CADD, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_CADD.rds")
write_tsv(gnomAD_main_table_full_cCREs_CADD, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_CADD.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_mean, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_mean.rds")
write_tsv(gnomAD_main_table_full_cCREs_mean, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_mean.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_mean_in_TF, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_mean_in_TF.rds")
write_tsv(gnomAD_main_table_full_cCREs_mean_in_TF, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_mean_in_TF.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_mean_in_rep, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_mean_in_rep.rds")
write_tsv(gnomAD_main_table_full_cCREs_mean_in_rep, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_mean_in_rep.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_K562, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562.rds")
write_tsv(gnomAD_main_table_full_cCREs_K562, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_K562_in_TF, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_in_TF.rds")
write_tsv(gnomAD_main_table_full_cCREs_K562_in_TF, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_in_TF.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_K562_in_rep, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_in_rep.rds")
write_tsv(gnomAD_main_table_full_cCREs_K562_in_rep, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_in_rep.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_HepG2, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2.rds")
write_tsv(gnomAD_main_table_full_cCREs_HepG2, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_HepG2_in_TF, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2_in_TF.rds")
write_tsv(gnomAD_main_table_full_cCREs_HepG2_in_TF, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2_in_TF.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_HepG2_in_rep, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2_in_rep.rds")
write_tsv(gnomAD_main_table_full_cCREs_HepG2_in_rep, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2_in_rep.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_SKNSH, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_SKNSH.rds")
write_tsv(gnomAD_main_table_full_cCREs_SKNSH, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_SKNSH.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_SKNSH_in_TF, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_SKNSH_in_TF.rds")
write_tsv(gnomAD_main_table_full_cCREs_SKNSH_in_TF, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_SKNSH_in_TF.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_SKNSH_in_rep, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_SKNSH_in_rep.rds")
write_tsv(gnomAD_main_table_full_cCREs_SKNSH_in_rep, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_SKNSH_in_rep.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_mean_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_mean_ref.rds")
write_tsv(gnomAD_main_table_full_cCREs_mean_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_mean_ref.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_K562_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_ref.rds")
write_tsv(gnomAD_main_table_full_cCREs_K562_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_ref.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_HepG2_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2_ref.rds")
write_tsv(gnomAD_main_table_full_cCREs_HepG2_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2_ref.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_SKNSH_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_SKNSH_ref.rds")
write_tsv(gnomAD_main_table_full_cCREs_SKNSH_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_SKNSH_ref.tsv.gz"))
saveRDS(gnomAD_main_table_full_in_TF_mean, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_mean.rds")
write_tsv(gnomAD_main_table_full_in_TF_mean, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_mean.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_TF_K562, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_K562.rds")
write_tsv(gnomAD_main_table_full_in_TF_K562, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_K562.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_TF_HepG2, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_HepG2.rds")
write_tsv(gnomAD_main_table_full_in_TF_HepG2, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_HepG2.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_TF_SKNSH, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_SKNSH.rds")
write_tsv(gnomAD_main_table_full_in_TF_SKNSH, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_SKNSH.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_TF_mean_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_mean_ref.rds")
write_tsv(gnomAD_main_table_full_in_TF_mean_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_mean_ref.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_TF_K562_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_K562_ref.rds")
write_tsv(gnomAD_main_table_full_in_TF_K562_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_K562_ref.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_TF_HepG2_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_HepG2_ref.rds")
write_tsv(gnomAD_main_table_full_in_TF_HepG2_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_HepG2_ref.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_TF_SKNSH_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_SKNSH_ref.rds")
write_tsv(gnomAD_main_table_full_in_TF_SKNSH_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_TF_SKNSH_ref.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_rep_mean, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_mean.rds")
write_tsv(gnomAD_main_table_full_in_rep_mean, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_mean.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_rep_K562, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_K562.rds")
write_tsv(gnomAD_main_table_full_in_rep_K562, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_K562.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_rep_HepG2, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_HepG2.rds")
write_tsv(gnomAD_main_table_full_in_rep_HepG2, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_HepG2.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_rep_SKNSH, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_SKNSH.rds")
write_tsv(gnomAD_main_table_full_in_rep_SKNSH, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_SKNSH.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_rep_mean_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_mean_ref.rds")
write_tsv(gnomAD_main_table_full_in_rep_mean_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_mean_ref.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_rep_K562_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_K562_ref.rds")
write_tsv(gnomAD_main_table_full_in_rep_K562_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_K562_ref.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_rep_HepG2_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_HepG2_ref.rds")
write_tsv(gnomAD_main_table_full_in_rep_HepG2_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_HepG2_ref.tsv.txt"))
saveRDS(gnomAD_main_table_full_in_rep_SKNSH_ref, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_SKNSH_ref.rds")
write_tsv(gnomAD_main_table_full_in_rep_SKNSH_ref, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_in_rep_SKNSH_ref.tsv.txt"))
saveRDS(gnomAD_main_table_full_cCREs_category, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_category.rds")
write_tsv(gnomAD_main_table_full_cCREs_category, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_category.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_mean_category, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_mean_category.rds")
write_tsv(gnomAD_main_table_full_cCREs_mean_category, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_mean_category.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_K562_category, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_category.rds")
write_tsv(gnomAD_main_table_full_cCREs_K562_category, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_category.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_HepG2_category, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2_category.rds")
write_tsv(gnomAD_main_table_full_cCREs_HepG2_category, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2_category.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_SKNSH_category, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_SKNSH_category.rds")
write_tsv(gnomAD_main_table_full_cCREs_SKNSH_category, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_SKNSH_category.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_mean_mean, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_mean_mean.rds")
write_tsv(gnomAD_main_table_full_cCREs_mean_mean, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_mean_mean.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_K562_K562, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_K562.rds")
write_tsv(gnomAD_main_table_full_cCREs_K562_K562, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_K562.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_HepG2_HepG2, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2_HepG2.rds")
write_tsv(gnomAD_main_table_full_cCREs_HepG2_HepG2, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2_HepG2.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_SKNSH_SKNSH, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_SKNSH_SKNSH.rds")
write_tsv(gnomAD_main_table_full_cCREs_SKNSH_SKNSH, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_SKNSH_SKNSH.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_emVar_cat_mean, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_emVar_cat_mean.rds")
write_tsv(gnomAD_main_table_full_cCREs_emVar_cat_mean, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_emVar_cat_mean.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_emVar_cat_K562, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_emVar_cat_K562.rds")
write_tsv(gnomAD_main_table_full_cCREs_emVar_cat_K562, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_emVar_cat_K562.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_emVar_cat_HepG2, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_emVar_cat_HepG2.rds")
write_tsv(gnomAD_main_table_full_cCREs_emVar_cat_HepG2, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_emVar_cat_HepG2.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_emVar_cat_SKNSH, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_emVar_cat_SKNSH.rds")
write_tsv(gnomAD_main_table_full_cCREs_emVar_cat_SKNSH, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_emVar_cat_SKNSH.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_K562_HepG2, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_HepG2.rds")
write_tsv(gnomAD_main_table_full_cCREs_K562_HepG2, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_HepG2.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_K562_SKNSH, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_SKNSH.rds")
write_tsv(gnomAD_main_table_full_cCREs_K562_SKNSH, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_K562_SKNSH.tsv.gz"))
saveRDS(gnomAD_main_table_full_cCREs_HepG2_SKNSH, "../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2_SKNSH.rds")
write_tsv(gnomAD_main_table_full_cCREs_HepG2_SKNSH, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_main_table_full_cCREs_HepG2_SKNSH.tsv.gz"))
