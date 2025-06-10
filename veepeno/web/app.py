from flask import Flask, render_template, request, jsonify, send_file, session, redirect, url_for
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user
import os
import subprocess
import json
from datetime import datetime
import secrets

app = Flask(__name__)
app.secret_key = os.environ.get('FLASK_SECRET_KEY', secrets.token_hex(32))

# Simple user management
class User(UserMixin):
    def __init__(self, id):
        self.id = id

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

@login_manager.user_loader
def load_user(user_id):
    if user_id == os.environ.get('WEB_ADMIN_USER'):
        return User(user_id)
    return None

@app.route('/')
@login_required
def index():
    return render_template('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        if (username == os.environ.get('WEB_ADMIN_USER') and 
            password == os.environ.get('WEB_ADMIN_PASSWORD')):
            user = User(username)
            login_user(user)
            return redirect(url_for('index'))
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

@app.route('/api/clients', methods=['GET'])
@login_required
def list_clients():
    try:
        result = subprocess.run(['/scripts/list_clients.sh'], 
                              capture_output=True, text=True)
        clients = json.loads(result.stdout)
        return jsonify(clients)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/clients', methods=['POST'])
@login_required
def create_client():
    client_name = request.json.get('name')
    if not client_name:
        return jsonify({'error': 'Client name is required'}), 400
    
    try:
        result = subprocess.run(['/scripts/generate_client.sh', client_name],
                              capture_output=True, text=True)
        if result.returncode == 0:
            return jsonify({'message': 'Client created successfully'})
        return jsonify({'error': result.stderr}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/clients/<client_name>', methods=['DELETE'])
@login_required
def revoke_client(client_name):
    try:
        result = subprocess.run(['/scripts/revoke_client.sh', client_name],
                              capture_output=True, text=True)
        if result.returncode == 0:
            return jsonify({'message': 'Client revoked successfully'})
        return jsonify({'error': result.stderr}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/clients/<client_name>/config')
@login_required
def download_config(client_name):
    config_path = f'/etc/openvpn/client-configs/{client_name}.ovpn'
    if not os.path.exists(config_path):
        return jsonify({'error': 'Client configuration not found'}), 404
    return send_file(config_path, as_attachment=True)

@app.route('/api/status')
@login_required
def vpn_status():
    try:
        result = subprocess.run(['/scripts/get_status.sh'],
                              capture_output=True, text=True)
        status = json.loads(result.stdout)
        return jsonify(status)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080) 