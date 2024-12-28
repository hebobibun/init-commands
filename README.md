# Development Setup Scripts

I'm too lazy to command the same commands over and over again. This repository contains a collection of installation scripts to quickly set up essential development tools on my machine (Ubuntu).

## Available Scripts

### 1. `install_go.sh`
Installs a specified version of Go programming language.

**Usage:**

```bash
./install_go.sh <version> # e.g., ./install_go.sh 1.22.7
```

- It will check if the requested version is already cached in `/opt/go-versions`.

- If not, it will download the tarball and extract it to the cache directory.

- Then it will create a symbolic link to the cache directory.

- Finally, it will update the PATH and environment variables in `.bashrc`.

### 2. `install_laravel.sh`
Installs Dependencies, and creates a new Laravel project.

**Usage:**

```bash
./install_laravel.sh
```

then follow the instructions. 

Input your project name and database configuration.

the database name will be the project name with `_db` suffix.

### 3. `install_protoc.sh`
Installs a specified version of the Protocol Buffers compiler (protoc) and Go plugins.

**Usage:**

```bash
./install_protoc.sh <version> # e.g., ./install_protoc.sh 29.0
```

## Contributing

Contributions are welcome! If you have any improvements or additions to these scripts, please submit a pull request.