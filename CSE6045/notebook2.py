######################################################################
################              Excercise 1        #####################
######################################################################
def normalize_string(s):
    assert type (s) is str
    ###
    ### YOUR CODE HERE
    ###
    return ''.join([c for c in s.lower() if c.isalpha() or c.isspace()])


######################################################################
################              Excercise 2        #####################
######################################################################
def get_normalized_words (s):
    assert type(s) is str
    ###
    ### YOUR CODE HERE
    ###
    import re
    # "normalize" s
    s = normalize_string(s).strip()
    return re.split('\s+', s)


######################################################################
################              Excercise 3        #####################
######################################################################
def make_itemsets(words):
    ###
    ### YOUR CODE HERE
    ###
    return [set(s) for s in words]


######################################################################
################              Excercise 4        #####################
######################################################################
from collections import defaultdict
import itertools # Hint!

def update_pair_counts (pair_counts, itemset):
    """
    Updates a dictionary of pair counts for
    all pairs of items in a given itemset.
    """
    assert type (pair_counts) is defaultdict

    ###
    ### YOUR CODE HERE
    ###
    for pair in itertools.combinations(itemset,2):
        pair_counts.update({pair: pair_counts[pair] + 1})
        rev = tuple(reversed(pair))
        pair_counts.update({rev: pair_counts[rev] + 1})


######################################################################
################              Excercise 5        #####################
######################################################################
def update_item_counts(item_counts, itemset):
    ###
    ### YOUR CODE HERE
    ###
    for item in itemset:
        for x in item:
            item_counts.update({x: item_counts[x]+1})


######################################################################
################              Excercise 6        #####################
######################################################################
def filter_rules_by_conf (pair_counts, item_counts, threshold):
    rules = {} # (item_a, item_b) -> conf (item_a => item_b)
    ###
    ### YOUR CODE HERE
    ###
    # iterate over all pair_count keys
    for pair, freq in pair_counts.items():
        # determine if it meets the threshold
        conf = freq / item_counts[pair[0]]
        print('Pair: %s  |  Word: %s  |  conf: %f' % (pair, pair[0], conf))
        if conf >= threshold:
            rules[pair] = conf     
    return rules


######################################################################
################              Excercise 7        #####################
######################################################################
def find_assoc_rules(receipts, threshold):
    ###
    ### YOUR CODE HERE
    ###
    pair_counts = defaultdict(int)
    item_counts = defaultdict(int)
    for itemset in receipts:
        # 1 - Create pair count
        update_pair_counts(pair_counts=pair_counts, itemset=itemset)
        # 2 - Update item counts
        update_item_counts(item_counts=item_counts, itemset=itemset)
    rules = filter_rules_by_conf(pair_counts=pair_counts, item_counts=item_counts, threshold=threshold)
    return rules


######################################################################
################              Excercise 8        #####################
######################################################################
# Generate `latin_rules`:
###
### YOUR CODE HERE
###

# 1 - get list of words
words = get_normalized_words(latin_text)
# 2 - convert to itemsets
itemset = make_itemsets(words)
# 3 - get assoc rules
latin_rules = find_assoc_rules(receipts=itemset, threshold=0.75)


######################################################################
################              Excercise 9        #####################
######################################################################
def intersect_keys(d1, d2):
    assert type(d1) is dict or type(d1) is defaultdict
    assert type(d2) is dict or type(d2) is defaultdict
    ###
    ### YOUR CODE HERE
    ###
    return set( d1.keys() ) & set( d2.keys() )


######################################################################
################             Excercise 10        #####################
######################################################################
###
### YOUR CODE HERE
###

###########################
## get the English rules ##
###########################
# 1 - get list of words
english_words = get_normalized_words(english_text)
# 2 - convert to itemsets
english_itemset = make_itemsets(english_words)
# 3 - get assoc rules
english_rules = find_assoc_rules(receipts=english_itemset, threshold=0.75)

###########################
## get the common rules  ##
###########################
common_high_conf_rules = intersect_keys(latin_rules, english_rules)

print("High-confidence rules common to _lorem ipsum_ in Latin and English:")
print_rules(common_high_conf_rules)


######################################################################
################             Excercise 11        #####################
######################################################################
###
### YOUR CODE HERE
###

basket_rules = defaultdict(int)

item_counts = defaultdict(int)

for grocery_str in groceries_file.split('\n'):
#     print('GROCERY_STR = ', grocery_str)
    # 1 - get list of words
#     words = get_normalized_words(grocery_str)
    words = grocery_str.split(',')
    for word in grocery_str.split(','):
        item_counts[word] += 1
    

for grocery_str in groceries_file.split('\n'):
    words = grocery_str.split(',')
#     print('ITEMS: ', words)
    # 2 - filter out words that do not occur MIN_COUNT
    # this filters out everything
    words = [word for word in words if item_counts[word] >= MIN_COUNT]
    
    # 2 - convert to itemsets
    itemset = make_itemsets(words)
    # 3 - get assoc rules
    rules = find_assoc_rules(receipts=itemset, threshold=THRESHOLD)
    print('RULES = ', rules)
    if not len(basket_rules):
        basket_rules = rules
        continue
    # 4 - Get the common pairs
    common_pairs = intersect_keys(basket_rules, rules)
    for pair in common_pairs:
        basket_rules.update({pair: rules[pair]})