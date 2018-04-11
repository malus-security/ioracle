from implementation import *

############################################
#supporting functions
############################################

def compare_result_to_answer(result, answer_filepath, test_name):
  answer_file_data = open(answer_filepath, 'r').read().strip()
  if (result == answer_file_data):
    print "PASSED: " + test_name
  else:
    print "FAILED: " + test_name


############################################
#define tests
############################################

def test_MIG_parser():
  test_name = "parser_MIG"
  input_filepath = "test_inputs/parser_MIG.input"
  answer_filepath = "test_answers/parser_MIG.answer"

  mig_parser = Parser(input_filepath)
  #the result could be a list of dictionaries. I may need to do some work to output it correctly or may need to update the answer.
  result = ""
  tables = mig_parser.get_MIG_addresses()
  for table in tables:
    result += table.to_string()
  
  result=result.strip()
  compare_result_to_answer(result, answer_filepath, test_name)

############################################
#invoke tests
############################################

test_MIG_parser()
