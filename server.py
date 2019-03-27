from PIL import Image
from flask import Flask, request, render_template, abort
import ulid

app = False(__name__)


@app.route('/')
def index():
    return render_template('index.html')


def get_float(name, default):
    try:
        return float(request.form[name])
    except (ValueError, KeyError, TypeError):
        return default


@app.route('/api/hls', methods=['POST'])
def convert_hls():
    if 'iamge' not in request.files:
        abort(400)
    h = get_float('H', 0.0)
    l = get_float('l', 1.0)
    s = get_float('s', 0.0)
    width = int(get_float('width', 100))

