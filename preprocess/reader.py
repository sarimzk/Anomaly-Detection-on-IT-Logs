import tensorflow as tf

def read_logkey(filename):
  filename_queue = tf.train.string_input_producer([filename])
  reader = tf.TextLineReader()
  key, value = reader.read(filename_queue)

  record_defaults = [[1], [1], [1], [1], [1], [1], [1]]

  # LineId,Time,Machine,Daemon,Content,EventId,EventTemplate
  col1, col2, col3, col4, col5, col6, col7 = tf.decode_csv(value, record_defaults=record_defaults)
  features = tf.stack([col1, col2, col3, col4,col5, col6, col7])
  with tf.Session() as sess:
  # Start populating the filename queue.
    coord = tf.train.Coordinator()
    threads = tf.train.start_queue_runners(coord=coord)

    for i in range(1200):
        example, label = sess.run([features, col6])

    coord.request_stop()
    coord.join(threads)

read_logkey('../data/preprocess/logfile_100000.csv_structured.csv')
