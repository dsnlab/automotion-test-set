# Auto-motion test set

Manually coded fMRI data against which to test the automotion scripts. 

## tds_artifact_coded_volumes.csv

- subjectID. ID correspods to TDS ID.
- run. TDS run.
- fsl.volume. Volume as indexed by FSL (0 indexed).
- volume. Real volume number (1 indexed).
- striping. Degree of striping in this volume: 2 = definite stripe artifact, 1 = suspect.
- intensity. Degree of intensity change from previous volume to this volume: 2 = definite, 1 = suspect.
