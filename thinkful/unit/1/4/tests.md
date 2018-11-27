# Does a new supplement help people sleep better?

## Versions
  1. A (control) - original/existing supplement
  2. B (experimental) - new formula
## Sample
  1. Randomly select a sample from all of your customers, then divide this sample in half and assign one to the control group and the remaining to the experimental group.
    * Need to ensure that characteristics such as age and gender are similarly represented in each sample 
## Hypothesis
  1. The newly formulated supplement results in better sleep.
## Outcome
  1. As we want to avoid using self-reported data (like duration of sleep) as our measurable metric (KPI), we will simply use the total sales per a fixed time period (eg. bottles per month)
## Other
  1. This KPI might very well suffer seasonality bias, but conducting the experiment at the same time should reduce this effect. 

# Will new uniforms help a gym's business?

1. The first thing to do in most experimental design is to get a clearer definition of the question at hand. A gym's business could indicate a lot of things: increased membership, increased consistency among members, increased referral rate or even increased concession sales (protein shakes). We will run into sampling/bias errors for the first question, so let's tackle the question of will new uniforms lead to longer times spent at the gym. Furthermore, the question is fairly ambiguous, does the new uniform only have a different color than the original? Or does it also have a new design? We need to try to identify individual factors, rather than multiple factors at once. 
2. **Versions**
    * This question will require we take time into account: day and time of week need to be consistent among the groups. This introduces the problem of staff wearing both uniforms during the same time slot, so a lot of attention must be paid to sampling. 
    * **A** - control group, gym staff wear existing uniforms 
    * **B** - gym staff wear new uniforms
3. **Sample**
    * First a time series analysis must be conducted to determine if there are significant differences in time spent at the gym (daily/hourly). If there is no statistically significant difference, our sampling becomes easy. If, however, there is, we might not be able to conduct the A/B test with regard to this question.
    * Let's assume that the gym in question is only open 12 hours a day, 7 days a week (a total of 84 hours). Thus, we partition the time slots into 42 hours each, and randomly assign our customers to, say, 5 1-hour time slots for the week. Age and gender should also be taken into consideration when sampling, both groups should contain a comparable mixture of genders and ages.
5. **Hypothesis**
    * The new uniforms (color change) will increase the typical time spent at the gym.
4. Outcome:
    * The time spent at the gym is easily recorded by check-in and check-out timestamps (members will be required to sign in at the front desk before and after each session
    * The gym will also know the uniforms worn for a particular time slot. We can then compute key metrics (such as average time spent) for each group.  


# Will a new homepage improve my online exotic pet rental business?

1. Let's define improve: increase sales. 
2. Versions:
    * **A** - control group - old homepage
    * **B** - experimental group - new homepage
3. Sample:
    * We need to ensure homogeneity among the two groups, which will require us to collect additional information such as gender, age and existing pets. We can record the IP address of all customers, and from this we can obtain a geographic location which also needs to be even among the 2 groups. Timestamps will also need to be accounted for, from these we can get the time of the day that customer visited our page, how long they stay on our site, and we can even record clicks. 
4. Hypothesis:
    * We guess that a newly designed homepage will lead to increased conversion rates.
5. **Outcome**
    * Again, this is all dependent on the question being asked. In regard to conversion rates (sales), this number is easily measured. Same with clicks and time spent on website. 


# If I put 'please read' in the email subject will more people read my emails?

1. This is a rather vague question: how do we measure if a person has read my email? Let's say that the email asks for users to reply or click a link. This information is actually measurable, a person actually reading an email is quite subjective. 
2. **Versions** 
    * We just randomly assign people to receive one of the two emails.
3. **Sample**
    * If we are able to collect additional information such as gender, age and location this information should be consistent among the two groups.
4. **Hypothesis**
    * Adding "please read" to an email subject will increase the response rate (reply or clicking a link). 
5. **Outcome**
    * The response rate to an email. We can also use the time a reply was sent, or when a link was clicked, to see if the time of day is also a factor in modulating the response rate.