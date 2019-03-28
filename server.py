from pathlib import Path

from PIL import Image
from flask import Flask, request, make_response, abort, url_for
import ulid
import numpy as np

app = Flask(__name__)


def get_working_dir():
    data = Path('_data')
    key = str(ulid.ulid())
    p = data / key
    p.mkdir()
    return p, key


@app.route('/')
def index():
    with open('index.html') as f:
        return make_response(f.read())


def get_float(name, default):
    try:
        return float(request.form[name])
    except (ValueError, KeyError, TypeError):
        return default


@app.route('/api/hls', methods=['POST'])
def convert_hls():
    if 'image' not in request.files:
        abort(400)
    wd, key = get_working_dir()
    fs = request.files['image']
    h = get_float('H', 0.0)
    l = get_float('l', 1.0)
    s = get_float('s', 0.0)
    width = int(get_float('width', 100))

    img = Image.open(fs)
    img = img.resize((width, int(width / img.size[0] * img.size[1])))
    img.save(str(wd / 'origin.jpg'))

    img_h, img_s, img_v = img.convert('HSV').split()
    img_h = Image.fromarray((np.array(img_h) / 255 + h) % 1.0 * 255)
    img_s = Image.fromarray((np.array(img_s) / 255 + h) % 1.0 * 255)
    img_v = Image.fromarray(np.array(img_h, dtype=np.float32) * l)
    print(img_h.mode)
    print(img_s.mode)
    print(img_v.mode)
    img = Image.merge('HSV', (img_h, img_s, img_v))
    img = img.convert('RGB')
    img.save(str(wd / 'convert.jpg'))

    return key


if __name__ == "__main__":
    app.run(debug=True)
