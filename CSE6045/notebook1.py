####################################
############## PART 0 ##############
####################################

###
### YOUR CODE HERE
###
x_float=1.


def strcat_ba(a, b):
    assert type(a) is str, f"Input argument `a` has `type(a)` is {type(a)} rather than `str`"
    assert type(b) is str, f"Input argument `b` has `type(b)` is {type(b)} rather than `str`"
###
### YOUR CODE HERE
###
    return b+a


def strcat_list(L):
    assert type(L) is list
    ###
    ### YOUR CODE HERE
    ###
    return "".join([substr for substr in L[::-1]])



def is_number(x):
    """Returns `True` if `x` is a number-like type, e.g., `int`, `float`, `Decimal()`, ..."""
    from numbers import Number
    return isinstance(x, Number)
    
def floor_fraction(a, b):
    assert is_number(a) and a >= 0
    assert is_number(b) and b > 0
    ###
    ### YOUR CODE HERE
    ###
    return int(a//b)


def ceiling_fraction(a, b):
    assert is_number(a) and a >= 0
    assert is_number(b) and b > 0
    ###
    ### YOUR CODE HERE
    ###
    return int(-(-a//b))


def report_exam_avg(a, b, c):
    #assert is_number(a) and is_number(b) and is_number(c)
    ###
    ### YOUR CODE xtHERE
    ###
    x: int = (a+b+c)/3
    return f'Your average score: {x:.1f}'


def count_word_lengths(s):
    assert all([x.isalpha() or x == ' ' for x in s])
    assert type(s) is str
    ###
    ### YOUR CODE HERE
    ###
    return [len(el) for el in s.split()]

####################################
############## PART 1 ##############
####################################

def minmax(L):
    assert hasattr(L, "__iter__")
    ###
    ### YOUR CODE HERE
    ###
    return (min(L), max(L))

def remove_all(L, x):
    assert type(L) is list and x is not None
    ###
    ### YOUR CODE HERE
    ###
    l_copy = L.copy()
    return list(filter((x).__ne__, l_copy))

def compress_vector(x):
    assert type(x) is list
    d = {'inds': [], 'vals': []}
    ###
    ### YOUR CODE HERE
    ###
    for index, value in enumerate(x):
        if value != 0.0:
            d['inds'].append(index)
            d['vals'].append(value)
    return d


def decompress_vector(d, n=None):
    # Checks the input
    assert type(d) is dict and 'inds' in d and 'vals' in d, "Not a dictionary or missing keys"
    assert type(d['inds']) is list and type(d['vals']) is list, "Not a list"
    assert len(d['inds']) == len(d['vals']), "Length mismatch"
    
    # Determine length of the full vector
    i_max = max(d['inds']) if d['inds'] else -1
    if n is None:
        n = i_max+1
    else:
        assert n > i_max, "Bad value for full vector length"
        
    ###
    ### YOUR CODE HERE
    ###
    x=[0.0]*n
    for idx, val in zip(d['inds'], d['vals']):
        x[idx]=val
    return x


def find_common_inds(d1, d2):
    assert type(d1) is dict and 'inds' in d1 and 'vals' in d1
    assert type(d2) is dict and 'inds' in d2 and 'vals' in d2
    ###
    ### YOUR CODE HERE
    ###
    return list(set(d1['inds']).intersection(set(d2['inds'])))

####################################
############## PART 2 ##############
####################################

def get_students(grades):
    ###
    ### YOUR CODE HERE
    ###
    return [l[0] for i, l in enumerate(grades) if i > 0]

def get_assignments(grades):
    ###
    ### YOUR CODE HERE
    ###
    return grades[0][1:]

# Create a dict mapping names to lists of grades.
def build_grade_lists(grades):
    ###
    ### YOUR CODE HERE
    ###
    return {student[0]: [int(g) for g in student[1:]] for student in grades[1:]}



def build_grade_dicts(grades):
    ###
    ### YOUR CODE HERE
    ###
    assignments = get_assignments(grades)
    return {student[0]: {assignments[i]: int(g) for i,g in enumerate(student[1:])} for student in grades[1:]}

def build_avg_by_student(grades):
    ###
    ### YOUR CODE HERE
    ###
    from statistics import mean
    return {student[0]: mean([int(g) for g in student[1:]]) for student in grades[1:]}

def build_grade_by_asn(grades):
    ###
    ### YOUR CODE HERE
    ###
    d = {}
    for exam_idx in range(1,len(grades[0][1:])+1):
        d[f'Exam {exam_idx}'] = []

    for student_idx in range(1,len(grades)):
        if student_idx == 0:
            continue
        for exam_idx in range(1,len(grades[0][1:])+1):
            d[f'Exam {exam_idx}'].append(int(grades[student_idx][exam_idx]))
    return d

def build_avg_by_asn(grades):
    ###
    ### YOUR CODE HERE
    ###
    from statistics import mean
    d = {}
    for exam_idx in range(1,len(grades[0][1:])+1):
        d[f'Exam {exam_idx}'] = []

    for student_idx in range(1,len(grades)):
        if student_idx == 0:
            continue
        for exam_idx in range(1,len(grades[0][1:])+1):
            d[f'Exam {exam_idx}'].append(int(grades[student_idx][exam_idx]))
    # compute mean for each exam
    return {k: mean(v) for k,v in d.items()}

def get_ranked_students(grades):
    ###
    ### YOUR CODE HERE
    ###
    from statistics import mean
    d = {student[0]: [int(g) for g in student[1:]] for student in grades[1:]}
    # compute mean for each student
    d_avg = {k: mean(v) for k,v in d.items()}
    # sort by mean and return student names
    return sorted(d_avg, key=d_avg.get, reverse=True)