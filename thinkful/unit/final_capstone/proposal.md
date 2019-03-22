# Final Capstone: Machine Learning Approach to Quantum Mechanics


## Problem

Health care suffers from a lot of problems, one of which involves the drug discovery process. Typically, this involves expensive quantum mechanical simulations that screen the chemical compound space to identify potential molecules. One property that can really assist in identifying these candidate molecules is the enthalpy of atomization, which is the enthalpy change that accompanies the total separation of all atoms in a chemical substance.


## Proposal

I propose the development of a machine learning framework that will predict the enthalpy of atomization for a given molecular configuration. Here the molecular configuration will simply be a list of each atom present in the molecule, specifically the element as well as its’ 3-dimensional coordinates. This information is freely available on PubChem.


## Methods

This is an extension of my Unit 3 capstone, in which my model was trained on 16,242 molecules, each having at most 50 atoms comprised of only C, H, N, O, P and S elements. I propose to build 2 models, one being a boosted model (XGBoost) and the other a LSTM (or GRU) recurrent neural network. Furthermore, I would like to use an additional 200,000 molecules, and perform some additional feature engineering (some bonding properties).

I briefly outlined the process I used to engineer features in my capstone presentation ([slide deck](https://github.com/mkm29/DataScience/blob/master/thinkful/unit/3/capstone/PitchDeck.pdf), [RoboBohr](https://github.com/bhimmetoglu/RoboBohr)), I also want to include the element counts, molecular weight using atomic weights, valence electrons, bonding information and possibly sequence (C8H10N4O2).

An accurate model can assist researchers by essentially guiding them in the early stages of drug design; test only certain compounds. If any step of the drug to market process can be sped up, society stands to reap the benefits.

## Anticipated Challenges

  * **Computational complexity** : (time and memory) accompanying the increase in input data
    * I have already been using Kaggle to assist in this but finding the proper hyper-parameters to use is critical (as is the usage of a GPU).
  * Feature engineering
    * I have already reached out to a biochemistry PhD, need help coming up with some basic chemistry-related features given only PubChem data
