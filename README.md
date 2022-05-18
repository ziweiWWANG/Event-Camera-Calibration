## For academic use only

# Event Camera Calibration of Per-pixel Biased Contrast Threshold
Event cameras output asynchronous events to represent intensity changes with a high temporal resolution, even under extreme lighting conditions. Currently, most of the existing works use a single contrast threshold to estimate the intensity change of all pixels. However, complex circuit bias and manufacturing imperfections cause biased pixels and mismatch contrast threshold among pixels, which may lead to undesirable outputs. In this paper, we propose a new event camera model and two calibration approaches which cover event-only cameras and hybrid image-event cameras. When intensity images are simultaneously provided along with events, we also propose an efficient online method to calibrate event cameras that adapts to time-varying event rates. We demonstrate the advantages of our proposed methods compared to the state-of-the-art on several different event camera datasets.

Ziwei Wang, Yonhon Ng, Pieter van Goor, Robert Mahony

The paper was accepted by the Australasian Conf. Robotics and Automation (ACRA 2019) in Adelaide, Australia.

## Publications
### ACRA 2019 conference version
[https://ssl.linklings.net/conferences/acra/acra2019_proceedings/views/includes/files/pap135s1-file1.pdf](https://ssl.linklings.net/conferences/acra/acra2019_proceedings/views/includes/files/pap135s1-file1.pdf)

### arXiv verison
[https://arxiv.org/pdf/2012.09378.pdf](https://arxiv.org/pdf/2012.09378.pdf)

## Citation
If you use or discuss our paper, please cite as follows:
<pre>
@InProceedings{wang19acra,
	author        = {Wang, Ziwei and Ng, Yonhon and van Goor, Pieter and Mahony, Robert},
	title         = {Event Camera Calibration of Per-pixel Biased Contrast
	Threshold},
	booktitle     = {Australasian Conf. Robot. Autom. (ACRA)},
	year          = 2019
}
</pre>

## Event Camera Dataset
-----------------
Bright Grass: https://drive.google.com/open?id=1bLCdxPQaF22B4HsMnu9JWbNS6y2ORbEX

## Notes 
1. If you have any questions regarding this paper, please contact ziwei.wang1@anu.edu.au
