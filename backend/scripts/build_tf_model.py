# Build and export a small TensorFlow SavedModel used by /quizzes/generate
# Usage:
#   python scripts/build_tf_model.py
# Requires: tensorflow (pip install tensorflow-cpu)
import tensorflow as tf
import json, os

class QuizGen(tf.Module):
    def __init__(self):
        super().__init__()

    @tf.function(input_signature=[
        tf.TensorSpec(shape=[], dtype=tf.string),
        tf.TensorSpec(shape=[], dtype=tf.string),
        tf.TensorSpec(shape=[], dtype=tf.int32),
    ])
    def generate(self, topic, difficulty, num_questions):
        n = tf.maximum(1, tf.minimum(num_questions, 20))
        # Eager-friendly Python branch via tf.numpy_function for formatting
        def _py(topic_b, diff_b, n_i):
            t = topic_b.decode('utf-8').strip().title() or 'General Knowledge'
            d = diff_b.decode('utf-8').strip().lower() or 'medium'
            count = int(n_i)
            qs = []
            for i in range(count):
                qs.append({
                    'question': f'{t}: What is key concept #{i+1}?',
                    'options': [f'{t} term A{i+1}', f'{t} term B{i+1}', f'{t} term C{i+1}', f'{t} term D{i+1}'],
                    'answer_index': i % 4,
                    'explanation': f'In {t}, concept #{i+1} relates to {d} principles.'
                })
            out = {
                'title': f'{t} {d.capitalize()} Quiz',
                'topic': t,
                'difficulty': d,
                'questions': qs
            }
            return json.dumps(out).encode('utf-8')
        out_json = tf.numpy_function(_py, [topic, difficulty, n], Tout=tf.string)
        out_json.set_shape([])
        return out_json

def main():
    save_dir = os.path.join(os.path.dirname(__file__), '..', 'tf_model')
    save_dir = os.path.abspath(save_dir)
    os.makedirs(save_dir, exist_ok=True)
    module = QuizGen()
    tf.saved_model.save(module, save_dir, signatures={'generate': module.generate})
    print('SavedModel exported to', save_dir)

if __name__ == '__main__':
    main()
