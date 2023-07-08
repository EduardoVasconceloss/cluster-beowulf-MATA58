#!/bin/bash

# Função para mostrar uma lista de arquivos e diretórios em um diretório nos dois nodes
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
  # Checa se o arquivo ou diretório existe
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

# Função para executar um comando nos dois nodes
function executar_comando {
  local command="$1"
  local args="$2"

  echo "Executando o comando '$command' no Node1..."
  ssh node1 "$command" "$args"

  echo "Executando o comando '$command' no Node2..."
  ssh node2 "$command" "$args"
}

# Função para copiar arquivos ou diretórios nos dois nodes
function copiar {
  local source="$1"
  local destination="$2"

  # Checa se o arquivo ou diretório existe
  if [[ ! -e $source ]]; then
    echo "Error: Arquivo ou diretório '$source' não existe."
    return
  fi

  local exists_node1=$(ssh node1 "[ -e \"$source\" ] && echo 'true'")
  local exists_node2=$(ssh node2 "[ -e \"$source\" ] && echo 'true'")

  if [[ -n $exists_node1 && -n $exists_node2 ]]; then
    executar_comando "cp" "$source $destination"
  elif [[ -z $exists_node1 && -z $exists_node2 ]]; then
    echo "Error: Arquivo ou diretório '$source' não existe nos dois nodes."
  elif [[ -z $exists_node1 ]]; then
    echo "Error: Arquivo ou diretório '$source' não existe em Node1."
  else
    echo "Error: Arquivo ou diretório '$source' não existe em Node2."
  fi
}

# Função para mover ou renomear arquivos ou diretórios nos dois nodes
function mover {
  local options=""
  local source=""
  local destination=""

  if [[ $1 == "-r" ]]; then
    options="-r"
    source="$2"
    destination="$3"
    echo "Executando o comando 'mv' no Node1..."
    echo "Executando o comando 'mv' no Node2..."
    ssh node1 "cp -r" "$source $destination"
    ssh node2 "cp -r" "$source $destination"
    ssh node1 "rm -r" "$source"
    ssh node2 "rm -r" "$source"
  else
    source="$1"
    destination="$2"

    # Checa se o arquivo ou diretório existe
    if [[ ! -e $source ]]; then
      echo "Error: Arquivo ou diretório '$source' não existe."
      return
    fi

    local exists_node1=$(ssh node1 "[ -e \"$source\" ] && echo 'true'")
    local exists_node2=$(ssh node2 "[ -e \"$source\" ] && echo 'true'")

    if [[ -n $exists_node1 && -n $exists_node2 ]]; then
      executar_comando "mv" "$source $destination"
    elif [[ -z $exists_node1 && -z $exists_node2 ]]; then
      echo "Error: Arquivo ou diretório '$source' não existe nos dois nodes."
    elif [[ -z $exists_node1 ]]; then
      echo "Error: Arquivo ou diretório '$source' não existe em Node1."
    else
      echo "Error: Arquivo ou diretório '$source' não existe em Node2."
    fi
  fi
}

# Funções para definir permissões de um arquivo nos dois nodes
function definir_permissoes {
  local permissions="$1"
  local file="$2"

  # Checa se o arquivo ou diretório existe
  if [[ ! -e "$file" ]]; then
    echo "Error: File or directory '$file' does not exist."
    return
  fi

  local command="chmod $permissions \"$file\""
  executar_comando "$command"
}

# Função para criar um usuário nos dois nodes
function criar_usuario {
  local username="$1"

  # Checa se o usuário já existe nos dois nodes
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

# Função para criar um grupo nos dois nodes
function criar_grupo {
  local groupname="$1"

  # Checa se o grupo já existe nos dois nodes
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

# Função para deletar um arquivo ou diretório nos dois nodes
function deletar {
  local item="$1"

  # Checa se o arquivo ou diretório existe nos dois nodes
  local exists_node1=$(ssh node1 "[ -e \"$item\" ] && echo 'true'")
  local exists_node2=$(ssh node2 "[ -e \"$item\" ] && echo 'true'")

  if [[ -n $exists_node1 && -n $exists_node2 ]]; then
    echo "Deletando $item no Node1..."
    ssh node1 "rm -r \"$item\""

    echo "Deletando $item no Node2..."
    ssh node2 "rm -r \"$item\""
  elif [[ -n $exists_node1 ]]; then
    echo "Error: $item não encontrado no Node2."
  elif [[ -n $exists_node2 ]]; then
    echo "Error: $item não encontrado no Node1."
  else
    echo "Error: $item não encontrado nos dois nodes."
  fi
}

# Script
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
