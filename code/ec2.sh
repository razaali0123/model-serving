#!/bin/bash
# sudo mkfs -t xfs /dev/sdh
# sudo mkdir /home/ec2-user/data
# sudo mount /dev/sdh /home/ec2-user/data

# sudo chown -R ec2-user:ec2-user /home/ec2-user/data

# # (Optional) Set appropriate permissions
# sudo chmod -R 700 /home/ec2-user/data

mkdir /home/ec2-user/moondream
cd /home/ec2-user/moondream

python3 -m venv /home/ec2-user/moondream/venv

# Activate the virtual environment
source /home/ec2-user/moondream/venv/bin/activate

# Upgrade pip and install the required packages
pip install --upgrade pip


aws s3 cp --recursive s3://sagemaker-mlops-mlreply/code/ .
# python3 -m ensurepip --upgrade
pip install -r requirements.txt
pip install "fastapi[standard]"

echo "################################## THE END OF THE WORLD ###############################################"
echo "################################## THE END OF THE WORLD ###############################################"
echo "################################## THE END OF THE WORLD ###############################################"
echo "################################## THE END OF THE WORLD ###############################################"
echo "################################## THE END OF THE WORLD ###############################################"
echo "################################## THE END OF THE WORLD ###############################################"
echo "################################## THE END OF THE WORLD ###############################################"

uvicorn run:app --host 0.0.0.0 --port 8000

