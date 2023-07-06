#!/bin/bash

# Function to show the list of files in a directory on both nodes
function mostrar {
  if [ $# -eq 0 ]; then
    echo "Por favor, forneça o nome do diretório."
    return
  fi

  local directory="$1"
  local exists_node1=$(ssh node1 "[ -d \"$directory\" ] && echo 'true'")
  local exists_node2=$(ssh node2 "[ -d \"$directory\" ] && echo 'true'")
  local directory_exists=false

  if [[ -n $exists_node1 ]]; then
    echo "Listando arquivos no Node1:"
    ssh node1 "ls $directory"
    directory_exists=true
  else
    echo "Diretório "$directory" não existe em Node1."
  fi

  if [[ -n $exists_node2 ]]; then
    echo "Listando arquivos no Node2:"
    ssh node2 "ls $directory"
    directory_exists=true
  else
    echo "Diretório "$directory" não existe em Node2."
  fi

  if [[ $directory_exists == false ]]; then
    echo "Error: Diretório "$directory" não existe nos dois nodes."
  fi
}

# Function to execute a command on both nodes
function executar_comando {
  local command="$1"
  local args="$2"

  echo "Executando o comando '$command' no Node1..."
  ssh node1 "$command" "$args"

  echo "Executando o comando '$command' no Node2..."
  ssh node2 "$command" "$args"
}

# Function to copy files or directories between nodes
function copiar {
  local source="$1"
  local destination="$2"

  if [[ ! -e $source ]]; then
    echo "Error: Arquivo ou diretório '$source' não existe."
    return
  fi

  executar_comando "cp" "$source $destination"
}

# Function to move or rename files or directories on both nodes
function mover {
  local source="$1"
  local destination="$2"

  if [[ ! -e $source ]]; then
    echo "Error: Arquivo ou diretório '$source' não existe."
    return
  fi

  executar_comando "mv" "$source $destination"
}

# Function to define permissions for a user or group on both nodes
function definir_permissoes {
  local command="$1"
  local permissions="$2"
  local file="$3"

  if [[ ! -e "$file" ]]; then
    echo "Error: Arquivo ou diretório '$file' não existe."
    return
  fi

  executar_comando "$command" "$permissions \"$file\""
}

# Function to create a new user on both nodes
function criar_usuario {
  local username="$1"

  # Check if the user already exists on both nodes
  local exists_node1=$(ssh node1 "id -u $username > /dev/null 2>&1 && echo 'true'")
  local exists_node2=$(ssh node2 "id -u $username > /dev/null 2>&1 && echo 'true'")

  if [[ -n $exists_node1 && -n $exists_node2 ]]; then
    echo "Error: Usuário '$username' já existe nos dois nodes."
  elif [[ -n $exists_node1 ]]; then
    echo "Usuário '$username' já existe no Node1."
    echo "Criando usuário '$username' no Node2..."
    ssh node2 "useradd $username"
  elif [[ -n $exists_node2 ]]; then
    echo "Usuário '$username' já existe no Node2."
    echo "Criando usuário '$username' no Node1..."
    ssh node1 "useradd $username"
  else
    echo "Criando usuário '$username' no Node1..."
    ssh node1 "useradd $username"

    echo "Criando usuário '$username' no Node2..."
    ssh node2 "useradd $username"
  fi
}

# Function to create a new group on both nodes
function criar_grupo {
  local groupname="$1"

  # Check if the group already exists on both nodes
  local exists_node1=$(ssh node1 "getent group $groupname > /dev/null && echo 'true'")
  local exists_node2=$(ssh node2 "getent group $groupname > /dev/null && echo 'true'")

  if [[ -n $exists_node1 && -n $exists_node2 ]]; then
    echo "Error: Grupo '$groupname' já existe nos dois nodes."
  elif [[ -n $exists_node1 ]]; then
    echo "Grupo '$groupname' já existe no Node1."
    echo "Criando grupo '$groupname' no Node2..."
    ssh node2 "groupadd $groupname"
  elif [[ -n $exists_node2 ]]; then
    echo "Grupo '$groupname' já existe no Node2."
    echo "Criando grupo '$groupname' no Node1..."
    ssh node1 "groupadd $groupname"
  else
    echo "Criando grupo '$groupname' no Node1..."
    ssh node1 "groupadd $groupname"

    echo "Criando grupo '$groupname' no Node2..."
    ssh node2 "groupadd $groupname"
  fi
}

# Function to delete a file or directory on both nodes
function deletar {
  local item="$1"

  # Check if the file exists on both nodes
  local exists_node1=$(ssh node1 "[ -e \"$item\" ] && echo 'true'")
  local exists_node2=$(ssh node2 "[ -e \"$item\" ] && echo 'true'")

  if [[ -n $exists_node1 && -n $exists_node2 ]]; then
    echo "Deletando $item no Node1..."
    ssh node1 "rm \"$item\""

    echo "Deletando $item no Node2..."
    ssh node2 "rm \"$item\""
  elif [[ -n $exists_node1 ]]; then
    echo "Error: $item não encontrado no Node2."
  elif [[ -n $exists_node2 ]]; then
    echo "Error: $item não encontrado no Node1."
  else
    echo "Error: $item não encontrado nos dois nodes."
  fi
}

# Main script
read -p "Digite um comando: " command args

case $command in
  mostrar)
    mostrar $args
    ;;
  copiar)
    copiar $args
    ;;
  mover)
    mover $args
    ;;
  definir_permissoes)
    definir_permissoes $args
    ;;
  criar_usuario)
    criar_usuario $args
    ;;
  criar_grupo)
    criar_grupo $args
    ;;
  manipular_usuario_grupo)
    manipular_usuario_grupo $args
    ;;
  deletar)
    deletar $args
    ;;
  sincronizar)
    sincronizar $args
    ;;
  *)
    echo "Comando inválido."
    ;;
esac
