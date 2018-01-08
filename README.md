# Auto-motion test set

Manually coded fMRI data against which to test the automotion scripts. 

# Validation process
## Overview
- Compared three different ways of detecting motion artifacts: lasso logistic regression, SVM, manual coding rules
- Used accuracy and balanced accuracy to determine best process
- Assessed process in two datasets: TDS and FP

## Datasets
- TDS 
	- Random subset
	- 7702 volumes
	- Hand coded by Cameron
	- Coding
		- Striping + intensity change
		- 2 = yes, 1 = suspected, 0 = no
		- Only volumes that were coded yes on the striping dimension were used in the analysis
	- Variable key for `tds_artifact_coded_volumes.csv`
		- `subjectID` = ID correspods to TDS ID.
		- `run` = TDS run.
		- `fsl.volume` = Volume as indexed by FSL (0 indexed).
		- `volume` = Real volume number (1 indexed).
		- `striping` = Degree of striping in this volume
		- `intensity` = Degree of intensity change from previous volume to this volume
- FP
	- Entire dataset
	- 22780 volumes 
	- Hand coded by Dani, Norma, Marc, Theresa, and Nandi
	- Coding: 1 = yes, 0 = no

## Indicators
- `euclidian_trans_deriv` = Volume to volume change in Euclidian distance for translation. Acquired via `motion_check.r` script.
- `euclidian_rot_deriv` = Volume to volume change in Euclidian distance for rotation. Acquired via `motion_check.r` script.
- `Diff.mean` = Volume to volume change in mean volume intensity. Acquired via `calculate_global_intensities.r` script.
- `Diff.sd` = Volume to volume change in standard deviation volume intensity. Acquired via `calculate_global_intensities.r` script.
`freqtile_power_c` = Mean-centered power of spectral frequency for 11 frequency bins (range = ? to ? Hz). Acquired via `stripe_detect.r` script.

## Model development
- Data split into training and testing subsets with a split ratio of .75. Percentage of artifacts was balanced across training and testing subsets.
- Model development scripts:
	- `auto-motion-test_FP_develop.rmd` = develop models in training subset using FP data
	- `auto-motion-test_TDS_develop.rmd` = develop models in training subset using TDS data
- Model application scripts:
	- `auto-motion-test_FP_apply.rmd` = apply models developed on TDS data to FP data
	- `auto-motion-test_TDS_apply.rmd` = apply models developed on FP data to TDS data

### Lasso logistic regresison
- Used `glmnet::cv.glmnet()`
- N folds = 10
- `alpha = 1` specifies lasso penalty
- Loss measure = area under the curve
- Lambda = selected using `lambda.1se` 
- Determined cut threshold (i.e. threshold for yes and no) in the training data by plotting specificity versus sensitivity to identify where each was maximized. This specified the range of values that were then used to calculate accuracy. Values were selected based on balancing false positive and false negative rates, with preference for reducing false negatives.
- This model was then applied to the testing subset using the determined cut threshold and accuracy was calculated.

### SVM
- Used `caret::train()` with a linear svm classifier
- N folds = 10
- Loss measure = receiver operator curve
- Determined cut threshold (i.e. threshold for yes and no) in the training data by plotting specificity versus sensitivity to identify where each was maximized. This specified the range of values that were then used to calculate accuracy. Values were selected based on balancing false positive and false negative rates, with preference for reducing false negatives.
- This model was then applied to the testing subset using the determined cut threshold and accuracy was calculated.

### Manual coding
- Developed the rules on the training sample
- Calculated the mean and standard deviation for `Diff.mean` and `Diff.sd` across all subjects to characterize the distribution.
- Volumes were classified as artifacts within each category according to the following rules:
	- `trash.mean` = `Diff.mean` above or below 2 standard deviations from the mean
	- `trash.sd` = `Diff.sd` above or below 2 standard deviations from the mean
	- `trash.rp.tr` = `euclidian_trans_deriv` more than .25mm above or less than .25mm below 0 in Euclidian distance
	- `trash.rp.rot` = `euclidian_rot_deriv` more than .25mm above or less than .25mm below 0 in Euclidian distance
	- `trash.stripe` = less than -.035 mean-centered `tile_1` and greater than .00025 mean-centered `tile_10`
- Volumes were classified as artifacts if:
	- Positive indicator for `trash.stripe`
	- More than one positive indicator for `trash.mean`, `trash.sd`, `trash.rp.tr`, `trash.rp.rot`
	- The volume before and after are classified as artifacts based on the above rules
	- The second volume in a run was classified as an artifact, the first volume was also coded as an artifact
- Calculated accuracy in training and testing samples

## Model application
- Machine learning models developed on TDS and FP were saved and then applied to the other dataset using the cut thresholds determined during development

## Model comparison
- Accuracy metrics were compared for each model
- For both the TDS and FP datasets, performance was as follows: **Manual coding > SVM > lasso logistic regression**

## Visualization
- After models were applied, hits, false positives, and false negatives were visualized for each model, participant and run
- Volume number is plotted against the derivative of Euclidian translation
- For TDS, confidence of striping coding, and intensity changes were also included in the plot

# Conclusions
- Manual coding was the most accurate 
- Manual coding still relies on distributions (i.e. for changes in intensity mean and sd); could be improved in the future through automated parameter tuning
- The process appears to generalize across datasets
- It would be ideal to have a second person rate all of the volumes used in these analyses to increase the confidence of the coding
- Building the machine learning models on FP and applying to TDS seemed more stable as it was a much larger dataset
- Machine learning models could be improved by increasing the amount of training data
- There are still false positives and negatives. Plots should be evaluated and artifacts should be confirmed via manual inspection.



