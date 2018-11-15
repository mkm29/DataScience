# Research Proposal

## Problem

You suspect an increase in cheating on your exams in a particular class and you would like to implement a strategy to discourage cheating.

## Potential Solution

You design two, multiple-choice tests, both consist of the same questions but in different order. The selection process is critical here; to ensure randomization among the groups, you should shuffle the tests multiple times, and also shuffle the list of students and then assign test I to student I after shuffling.

## Method of Testing

In order to gauge the level of cheating, we will conduct a simple error similarity analysis on tests before you implement the anti-cheating strategy and after. A statistical procedure compares answers for pairs of students using those items on which both made errors. If the number of identical wrong answers is sufficiently greater than the number expected by chance and if the students were seated close together, then cheating is likely. Therefore, the design of questions and answers is key: you want all answer choices to be equally likely to be correct (do not include answers that are clearly wrong). This metric will give you an overall probability of students likely to have cheated. One key assumption I am making here is that you have access to location information of students for previous tests, if this information is not available you cannot prior testing information and will need to start from scratch (establish a baseline with only one test and then introduce multiple formats so that you can compare). If this probability decreases, the strategy is working.
