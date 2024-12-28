#!/bin/bash

# Script to install and run Laravel on WSL Ubuntu
set -e

# example : ./install_laravel.sh

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

# Prompt for the project name
read -p "Enter your Laravel project name: " PROJECT_NAME
DB_NAME="${PROJECT_NAME}_db"

# Prompt for database connection details
echo -e "${GREEN}Please enter your MySQL database connection details:${NC}"
read -p "DB_HOST [127.0.0.1]: " DB_HOST
read -p "DB_PORT [3306]: " DB_PORT
read -p "DB_USERNAME [root]: " DB_USERNAME
read -p "DB_PASSWORD [123]: " DB_PASSWORD

# Set defaults if the user doesn't input anything
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USERNAME="${DB_USERNAME:-root}"
DB_PASSWORD="${DB_PASSWORD:-123}"

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update package list
echo -e "${GREEN}Updating package list...${NC}"
sudo apt-get update -y

# Install PHP if not installed
if ! command_exists php; then
    echo -e "${GREEN}Installing PHP and required extensions...${NC}"
    sudo apt-get install -y php php-cli php-mbstring php-xml php-curl php-mysql unzip curl
else
    echo -e "${GREEN}PHP is already installed. Skipping...${NC}"
fi

# Install Composer if not installed
if ! command_exists composer; then
    echo -e "${GREEN}Installing Composer...${NC}"
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
else
    echo -e "${GREEN}Composer is already installed. Skipping...${NC}"
fi

# Install MySQL client if not installed
if ! command_exists mysql; then
    echo -e "${GREEN}Installing MySQL client...${NC}"
    sudo apt-get install -y mysql-client
else
    echo -e "${GREEN}MySQL client is already installed. Skipping...${NC}"
fi

# Create Laravel project if not exists
if [ ! -d "$PROJECT_NAME" ]; then
    echo -e "${GREEN}Creating Laravel project '${PROJECT_NAME}'...${NC}"
    composer create-project --prefer-dist laravel/laravel "$PROJECT_NAME"
else
    echo -e "${GREEN}Laravel project '${PROJECT_NAME}' already exists. Skipping...${NC}"
fi

# Navigate to project directory
cd "$PROJECT_NAME"

# Set up environment
echo -e "${GREEN}Setting up .env file...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Update database configuration in .env
sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=mysql/" .env
sed -i "s/^# DB_HOST=.*/DB_HOST=${DB_HOST}/" .env
sed -i "s/^# DB_PORT=.*/DB_PORT=${DB_PORT}/" .env
sed -i "s/^# DB_DATABASE=.*/DB_DATABASE=${DB_NAME}/" .env
sed -i "s/^# DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/" .env
sed -i "s/^# DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env

# Generate application key
echo -e "${GREEN}Generating application key...${NC}"
php artisan key:generate --ansi

# Create database
echo -e "${GREEN}Creating MySQL database '${DB_NAME}' if it doesn't exist...${NC}"
mysql -u "$DB_USERNAME" -p"$DB_PASSWORD" -h "$DB_HOST" -P "$DB_PORT" -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"

# Run migrations
echo -e "${GREEN}Running database migrations...${NC}"
php artisan migrate --force

# Set permissions for storage and bootstrap/cache
echo -e "${GREEN}Setting permissions for storage and bootstrap/cache...${NC}"
sudo chmod -R 775 storage bootstrap/cache
sudo chown -R $USER:www-data storage bootstrap/cache

# Start Laravel development server
echo -e "${GREEN}Starting Laravel development server...${NC}"
php artisan serve --host=0.0.0.0 --port=8000