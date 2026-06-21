FROM apache/airflow:2.9.1-python3.9
USER root

# Install Python dependencies
COPY requirements.txt /requirements.txt
RUN pip3 install --upgrade pip --proxy http://172.16.0.250:4343
RUN pip3 install --no-cache-dir -r /requirements.txt --proxy http://172.16.0.250:4343
