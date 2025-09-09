
import tensorflow as tf
import os, json

class QuizGen(tf.Module):
    def __init__(self):
        super().__init__()
        # pretend trained: store patterns in variables/constants
        self.prefix = tf.constant("ThinkStrikeTF")

    @tf.function(input_signature=[
        tf.TensorSpec(shape=[], dtype=tf.string),
        tf.TensorSpec(shape=[], dtype=tf.string),
        tf.TensorSpec(shape=[], dtype=tf.int32),
    ])
    def generate(self, topic, difficulty, num_questions):
        # generate templated questions tensors
        # Outputs: a JSON string of quiz content
        n = tf.maximum(1, tf.minimum(num_questions, 20))
        qs = []
        # convert tensors to python for simple loop with tf.constant strings
        t = topic.numpy().decode("utf-8").strip().title()
        d = difficulty.numpy().decode("utf-8").strip().lower()
        count = int(n.numpy())
        for i in range(count):
            q = {
                "question": f"{t}: What is key concept #{i+1}?",
                "options": [f"{t} term A{i+1}", f"{t} term B{i+1}", f"{t} term C{i+1}", f"{t} term D{i+1}"],
                "answer_index": (i % 4),
                "explanation": f"In {t}, concept #{i+1} relates to {d} difficulty principles."
            }
            qs.append(q)
        out = {
            "title": f"{t} {d.capitalize()} Quiz",
            "topic": topic.numpy().decode("utf-8"),
            "difficulty": d,
            "questions": qs
        }
        return tf.constant(json.dumps(out))

def main(save_dir):
    module = QuizGen()
    tf.saved_model.save(module, save_dir, signatures={'generate': module.generate})

if __name__ == "__main__":
    import sys
    main(sys.argv[1] if len(sys.argv)>1 else "tf_model_export")
