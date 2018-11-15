import pandas as pd
import numpy as np
import re


class CleanData:

    def __init__(self):
        print("initizing CleanData object")
        self.data = self.load_data()

    def clean_cost(self,x):
            # remove the currency symbol
            try:
                x = re.sub(r'\[^\d\.\,\s]+','',x)
                return float(x)
            except:
                return np.nan
    
    def get_id(self, cost, length):
        pattern = re.compile(r'(\d{7,8})')
        try:
            cost = str(cost).strip('\n')
            iterator = pattern.finditer(cost)
            for match in iterator:
                # looking for length 7
                start, end = match.span()[0], match.span()[1]
                if (end - start) == length:
                    return cost[start:end]
        except:
            return None

    def load_data(self):
        converters = {"COST (£) charged to Wellcome (inc VAT when charged)" : self.clean_cost}
        #df = pd.read_csv("WELLCOME_APCspend2013_forThinkful.csv", encoding="latin1", converters=converters)
        df = pd.read_csv("/Users/mitchellmurphy/DataScience/thinkful/unit/3/WELLCOME/WELLCOME_APCspend2013_forThinkful.csv", encoding="latin1", converters=converters)
        print("Read data: {}".format(df.head()))
        # rename our cols
        df.columns = ['PMID/PMCID', 'Publisher', 'Journal title', 'Article title', 'Cost']
        # drop missing for now
        df.dropna(subset=['PMID/PMCID','Journal title', 'Cost'], inplace=True)
        df["Journal title"] = df["Journal title"].apply(lambda x: x.lower() )
        df["PMCID"] = df["PMID/PMCID"].apply(self.get_id, length = 7)
        df["PMID"] = df["PMID/PMCID"].apply(self.get_id, length = 8)
        df.drop(["PMID/PMCID"], axis=1, inplace=True)
        # 999999 does not seem like a reasonable price. lets also drop these as they will 
        # this price does not make sense...dramatically effect our stats
        df = df.query("Cost != 999999.00")
        return df