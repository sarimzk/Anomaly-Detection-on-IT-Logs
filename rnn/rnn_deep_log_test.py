import numpy as np
from batch_generator import KerasBatchGenerator
from optparse import OptionParser
from keras.models import load_model
from loader import load_data

if "__main__"==__name__:
    parser = OptionParser()
    (options, args) = parser.parse_args()
    if len(args) == 1:
        num_steps = 30
        batch_size = 50
        num_epochs = 5

        data_path=args[0]
        train_data, test_data, valid_data, vocabulary, reversed_dictionary = load_data(data_path)
        model = load_model(data_path + "final_model.hdf5")
        dummy_iters = 40
        example_training_generator = KerasBatchGenerator(train_data, num_steps, 1, vocabulary,
                                                         skip_step=1)
        print("Training data:")
        for i in range(dummy_iters):
            dummy = next(example_training_generator.generate())
        num_predict = 10
        true_print_out = "Actual words: "
        pred_print_out = "Predicted words: "
        for i in range(num_predict):
            data = next(example_training_generator.generate())
            prediction = model.predict(data[0])
            predict_word = np.argmax(prediction[:, num_steps-1, :])
            true_print_out += reversed_dictionary[train_data[num_steps + dummy_iters + i]] + " "
            pred_print_out += reversed_dictionary[predict_word] + " "
        print(true_print_out)
        print(pred_print_out)
        # test data set
        dummy_iters = 40
        example_test_generator = KerasBatchGenerator(test_data, num_steps, 1, vocabulary, skip_step=1)
        print("Test data:")
        for i in range(dummy_iters):
            dummy = next(example_test_generator.generate())
        num_predict = 10
        true_print_out = "Actual words: "
        pred_print_out = "Predicted words: "
        for i in range(num_predict):
            data = next(example_test_generator.generate())
            prediction = model.predict(data[0])
            predict_word = np.argmax(prediction[:, num_steps - 1, :])
            true_print_out += reversed_dictionary[test_data[num_steps + dummy_iters + i]] + " "
            pred_print_out += reversed_dictionary[predict_word] + " "
        print(true_print_out)
        print(pred_print_out)
