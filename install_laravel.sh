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
sed -i "s/^# DB_HOST=.*/DB_HOST=127.0.0.1/" .env
sed -i "s/^# DB_PORT=.*/DB_PORT=3306/" .env
sed -i "s/^# DB_DATABASE=.*/DB_DATABASE=${DB_NAME}/" .env
sed -i "s/^# DB_USERNAME=.*/DB_USERNAME=root/" .env
sed -i "s/^# DB_PASSWORD=.*/DB_PASSWORD=123/" .env

# Generate application key
echo -e "${GREEN}Generating application key...${NC}"
php artisan key:generate --ansi

# Create database
echo -e "${GREEN}Creating MySQL database '${DB_NAME}' if it doesn't exist...${NC}"
mysql -u root -p -h 127.0.0.1 -P 3306 -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"

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
