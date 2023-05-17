# *Assessment of cognitive load in extreme environment*

[![License: MIT](https://img.shields.io/badge/license-CC%20BY--SA%204.0-blue.svg)](https://creativecommons.org/licenses/by-sa/4.0)

This is my master's thesis that I wrote during my final year of studying the
biomedical engineering program at the Faculty of Biomedical Engineering, CTU in
Prague. The work was made possible thanks to the [Hydronaut project](https://hydronaut.eu) under the
auspices of the European Space Agency (ESA). Unfortunately, the whole work is written
in the Czech language. I may translate it into English in the future.

### [Click here to read the thesis.](https://firebasestorage.googleapis.com/v0/b/mareksokol-e3c61.appspot.com/o/main.pdf?alt=media&token=e7535079-74f3-4463-b7b9-7fdc4eb9b3a2)

## Abstract
The thesis focuses on the assessment of cognitive load in extreme environments,
which is critical for the success and safety of individuals and teams performing
demanding and essential tasks. Traditional monitoring methods using
questionnaires or behavioral analysis may be impractical or even impossible in
extreme conditions. For this reason, there is a growing interest in using
peripheral biosignals for real-time cognitive load assessment. Specifically, the
thesis examines the impact of extreme environments, such as an analog space
mission, on the manifestations of cognitive load in electrical cardiac,
respiratory, and electrodermal activity. To assess the cognitive load, a new
multimodal approach is introduced based on the creation of physiological
features in the form of multivariate spatiotemporal causal patterns, allowing
for a unique encoding of specific cognitive states. A capsular neural network is
designed for synergic uniform integration of the physiological features to
capture spatiotemporal causal relations by exploiting autoencoder compression
capability. The proposed solution is tested on popular publicly available
benchmark datasets, including data from an analog space mission.

## Experimental part of the work
This thesis benefits from the second space analogue mission (mission DIANA),
which simulated a lunar landing and was carried out as part of the Hydronaut
project in the summer of 2022. The individual compartments of the mission had
the following roles: the control tower was the station on Earth, the MotherShip
orbited the lunar orbit, and the landing module (Lander) was on the surface of
the Moon. The individual compartments can be seen in the Figure 1.

<figure>
<img src="assets/github/map_en.png" style="width:100%"><figcaption align = "center"><b>Figure 1 - Detail, location and individual mission compartments (map source: Mapy.cz)</b></figcaption>
</figure>

A six-member crew was selected for the DIANA mission. Three individuals on the floating platform (MotherShip) and another three for the underwater station (Lander). Given that the underwater habitat involved a long-term saturation dive, the Lander crew was made up of professionally trained divers. The mission primarily served to examine the influence of personality characteristics and external factors on team dynamics during a long-term stay in an ICE environment. The whole experimental part is described in detail in the thesis itself.

<figure align = "center">
<img src="assets/figures/habitat.png" style="width:100%"><figcaption align = "center"><b>Figure 2 - H03 DeepLab and its schematic (source: Hydronaut Project a.s.)</b></figcaption>
</figure>

## Novel method for cognitive load assessment using multivariate spatiotemporal causal patterns
A multimodal approach to assess cognitive load using peripheral biosignals,
specifically using electrical cardiac, respiratory and electrodermal activity,
was developed as part of the thesis work. The Copula-Granger approach with Lasso
(ℓ1) regularization was chosen to capture time-causal relationships in the used
biosignals, which combines the concept of Granger causality with the theory of
copulas. However, it cannot be assumed that this captures all of the complex
dynamics present in biosignals. This problem is compensated for by using Gramian
Angular Fields. These patterns capture a certain kind of temporal and spatial
correlation within physiological signals.

<figure>
<img src="assets/github/f_scheme_en.png" style="width:100%"><figcaption align = "center"><b>Figure 3 - Scheme of physiological features creation</b></figcaption>
</figure>

For the purposes of classification tasks (cognitive load assessment), a capsular neural network architecture based on the solution presented by [Mazzia et al. (2021)](https://www.nature.com/articles/s41598-021-93977-0), Efficient-CapsNet, was proposed. To synergistically unify the generated physiological features, autoencoder compression into a single latent space is used to capture spatiotemporal causal relations across biosignals.

<figure>
<img src="assets/github/nn_scheme_en.png" style="width:100%"><figcaption align = "center"><b>Figure 4 - Schematic of the proposed capsular neural network model based on the <a href="https://github.com/EscVM/Efficient-CapsNet">Efficient-CapsNet</a> architecture. Each convolutional layer in the proposed solution is additionally followed by BatchNormalization, MaxPool2D and Dropout layers (scheme adapted from <a href="https://pubmed.ncbi.nlm.nih.gov/34901796/">Wang et al. (2021)</a>.</b></figcaption>
</figure>

## Acknowledgements
I would like to thank the supervisor of my master thesis, Mgr. Ksenia Sedová,
Ph.D. for help, advice, and professional management of this work. I would also
like to thank Ing. et Ing. Jan Hejda, Ph.D., for all-around help, a lot of
valuable and inspiring advice, suggestions adn recommendations. Last but not
least, I thank my family and all the friends who supported me in creating this
work.

### Contributors
* Marek Sokol - *Author*
* Mgr. Ksenia Sedova, Ph.D. - *Supervisor*
* Ing. et Ing. Jan Hejda, Ph.D. - *Consultant*