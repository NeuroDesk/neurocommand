-- -*- lua -*-
help([===[

----------------------------------
## itksnap/4.0.1 ##
itksnap is an image viewer for DICOM and NII files and supports manual segmentation of data.


Example:
```
itksnap
```

More documentation can be found here: http://www.itksnap.org/pmwiki/pmwiki.php

----------------------------------
]===])
whatis("itksnap_4.0.1_20230609.simg")
prepend_path("PATH", "/home/sebp/neurocommand/neurodesk/containers/itksnap_4.0.1_20230609")
setenv("FORCE_SPMMCR", "1")
setenv("SPMMCRCMD", "/home/sebp/neurocommand/neurodesk/containers/itksnap_4.0.1_20230609/itksnap_4.0.1_20230609.simg/opt/spm12/run_spm12.sh /home/sebp/neurocommand/neurodesk/containers/itksnap_4.0.1_20230609/itksnap_4.0.1_20230609.simg/opt/mcr/v97/ script")
setenv("FSLDIR", "/home/sebp/neurocommand/neurodesk/containers/itksnap_4.0.1_20230609/itksnap_4.0.1_20230609.simg/opt/fsl-test")
