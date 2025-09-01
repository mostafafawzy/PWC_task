# Use the official Python base image
FROM python:3.9-slim

# Set the working directory in the container
# We set it to a parent directory of your 'app' folder
WORKDIR /usr/src/app

# Copy the requirements file first to leverage Docker's build cache
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire 'app' directory into the container's working directory
COPY . .

# Expose the port your app will run on
EXPOSE 5000
ENV PYTHONPATH=/usr/src/app

# Run main.py when the container launches, specifying its full path
# The CMD command is relative to the WORKDIR
CMD ["python", "-m", "app.main"]
