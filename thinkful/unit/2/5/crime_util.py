import math
import warnings

from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
import statsmodels.formula.api as smf
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import cross_val_score, cross_val_predict
from scipy.stats import boxcox
from scipy.special import inv_boxcox


''' Global Variables '''

model_vars = ['population_log', "population_group",  "burglary_cube_root", "larceny_theft_cube_root"]



def read_data():
    florida = pd.read_excel('./florida_2017.xls')
    headers = ['city', 'population', 'violent_crime', 'murder', 'rape', 'robbery',
               'assault', 'property_crime', 'burglary', 'larceny_theft',
               'motor_vehicle_theft', 'arson']
    florida.columns = headers
    florida.set_index('city', inplace=True)

    # read in other states for validation purposes
    ohio = pd.read_excel('./ohio_2017.xls')
    ohio.columns = headers
    ohio.set_index('city', inplace=True)

    michigan = pd.read_excel('./michigan_2017.xls')
    michigan.columns = headers
    michigan.set_index('city', inplace=True)

    north_carolina = pd.read_excel('./north-carolina_2017.xls')
    north_carolina.columns = headers
    north_carolina.set_index('city', inplace=True)

    crime_cols = ['violent_crime', 'murder', 'rape', 'robbery',
                  'assault', 'property_crime', 'burglary', 'larceny_theft',
                  'motor_vehicle_theft', 'arson']
    # so we will want to remove some outliers
    florida = florida[florida.population < florida.population.quantile(0.9)]
    michigan = michigan[michigan.population < michigan.population.quantile(0.9)]
    north_carolina = north_carolina[north_carolina.population < north_carolina.population.quantile(0.9)]
    ohio = ohio[ohio.population < ohio.population.quantile(0.9)]

    return  florida, michigan, north_carolina, ohio



def transform_data(df):
    # add a log odds variable (do not include property crimes though)
    cols = ['violent_crime', 'murder', 'rape', 'robbery',
            'assault', 'burglary', 'larceny_theft',
            'motor_vehicle_theft', 'arson']
    df["log_odds"] = np.log1p(df.population / df[cols].sum(axis=1))

    # log population
    df["population_log"] = np.log(df.population)

    # log1p first adds 1 to x then logs the result
    df["property_crime_log"] = np.log1p(df.property_crime)


    # create a population_medium indicator variable
    # these are going to be relative to the population in each state
    # the medium group is the interquartile range on population (between 1st and 3rd quantiles)
    # population thresholds. simply uses the first 3 quantiles

    population_low = df.population.quantile(0.25)
    popullation_high = df.population.quantile(0.75)


    df["population_medium"] = (df.population.between(population_low, popullation_high)).astype("int")


    # create n population groups
    df["population_group"] = pd.cut(df.population, 5, labels=list(range(1, 6)))


    # create robbery dummy var
    df["has_robbery"] = np.where(df.robbery > 0, 1, 0)


    # because box-cox transforms require x>0, when property_crime is 0 we add 1, else we leave it alone
    df["property_crime_2"] = df["property_crime"].apply(lambda x: x + 1 if x == 0 else x)


    # burglary_cube_root
    df["burglary_cube_root"] = df.burglary ** (1 / 3)


    # assault_log
    df["assault_log"] = np.log1p(df.assault)


    # larceny_theft_cube_root
    df["larceny_theft_cube_root"] = df.larceny_theft ** (1 / 3)


    # robbery_log
    df["robbery_log"] = np.log1p(df.robbery)


    # motor_vehicle_theft_log
    df["motor_vehicle_theft_log"] = np.log1p(df.motor_vehicle_theft)

    return df



def boxcox_transform(df):
    bc = boxcox(df["property_crime_2"])
    df["property_crime_bc"] = bc[0]

    return df, bc[1]




def split(df):
    df_train = df.sample(frac=0.7, random_state=41)
    df_test_cities = list(set(df.index).difference(set(df_train.index)))
    df_test = df.loc[df_test_cities, :]
    return df_train, df_test



def build_model(train, test):
    # Now lets see how well we can predict the boxcox transform of property_crime

    formula = "property_crime_bc ~ " + ' + '.join(model_vars)

    lm1 = smf.ols(formula=formula, data=train).fit()
    print("-----\nTRAIN\n-----\n", lm1.summary())
    lm2 = smf.ols(formula=formula, data=test).fit()
    print("-----\nTEST\n-----\n", lm2.summary())


    model_train = LinearRegression()
    model_train.fit(train[model_vars], train["property_crime_bc"])
    model_test = LinearRegression()
    model_test.fit(test[model_vars], test["property_crime_bc"])
    return  model_train, model_test



''' Call this function once for the train set and once for the test set '''

def evaluate_model(model, df, bc_lambda, name):
    y_pred = cross_val_predict(model, df[model_vars], df["property_crime_bc"])
    cv = cross_val_score(model, df[model_vars], df["property_crime_bc"], cv=5)
    print("{}\n-------------------------------------------------------------\n".format(name))
    print(cv)
    print("cv average is = {:.2f}%".format(cv.mean() * 100))
    ''' return redisuals '''
    residuals = df["property_crime"] - inv_boxcox(y_pred, bc_lambda)

    print("Mean Residual: {}\nRMSE: {}".format(residuals.mean(), residuals.std()))
    print("Average Error: {}\n".format(np.abs(residuals).sum() / residuals.shape[0]))

    return residuals


