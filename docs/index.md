# Documentação Cluster Beowulf - MATA58

Bem vindo! Nessa documentação irei te ensinar como você pode realizar atividades em um cluster beowulf de maneira mais "automatizada" através de um script em bash.

## Configure o arquivo hosts da sua máquina

Na sua máquina, você deve declarar quem é o node1 e quem é o node2 e atribuir um IP para eles. Para fazer isso você deve alterar o arquivo "hosts", para isso, execute o seguinte comando:
```bash
nano /etc/hosts
```
Agora você pode modificar o arquivo, use meu arquivo hosts como referência.
```bash
127.0.0.1       localhost
127.0.1.1       node1.ufba      node1  
10.0.0.12       node2.ufba      node2

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# LEMBRE-SE! Mude os IPs e os hostnames de acordo com sua necessidade, um IP e hostname que sirvam para mim podem não servir para você e vice-versa.
```

## Vamos criar uma chave SSH para podemos conectar nosso cluster.

Antes de tudo, você deve mudar uma linha em um arquivo de configuração do debian executando o seguinte comando:
```bash
nano /etc/ssh/sshd_config

# Altere a linha que contém "PermitRootLogin", ela deve ficar desse jeito:
PermitRootLogin yes
```
Para aplicar as alterações feitas, reinicie sua máquina, você pode usar o comando "sudo systemctl reboot"

Para a conexão do cluster funcionar, precisamos da chave SSH. Somente assim as máquinas poderão comunicar-se entre si com segurança e agilidade.
Execute o seguinte comando nos dois nodes para gerar a chave SSH:
```bash
ssh-keygen
# Agora é só dar enter até cansar
```
Após isso, vamos criar um arquivo de configuração ssh nos dois nodes para automatizar a "passagem" das chaves SSH de um node para o outro
Execute esse comando:
```bash
nano ~/.ssh/config
```

Certo, falta colocar as configurações dentro do arquivo, então copie e cole as informações abaixo:
```bash
Host node1
    Hostname node1
    User root
Host node2
    Hostname node2
    User root

# LEMBRE-SE! Mude o 'hostname' de acordo com sua necessidade
```

Além disso, mude as permissões do arquivo de configuração nos dois nodes:
```bash
chmod 600 ~/.ssh/config
```

Por fim, execute esses comandos, nos dois nodes, para "enviar" a chave ssh de um node para o outro:
```bash
ssh-copy-id node1
ssh-copy-id node2
```

## Baixando o nosso cluster.sh

Baixe o arquivo "cluster.sh" que pode ser encontrado no repositório desse trabalho no github, através desse [link](https://github.com/EduardoVasconceloss/cluster-beowulf-MATA58/). Você também pode baixar esse repositório via comandos:
```bash
sudo apt install git
git clone https://github.com/EduardoVasconceloss/cluster-beowulf-MATA58.git
```
## Funcionalidades do cluster.sh

O nosso cluster tem 7 funcionalidades, sendo elas:
- mostrar: função que executa o comando "ls"
- copiar: função que executa o comando "cp"
- mover: função que executa o comando "mv"
- definir_permissoes: função que executa o comando "chmod"
- criar_usuario: função que executa o comando "useradd"
- criar_grupo: função que executa o comando "groupadd"
- deletar: função que executa o comando "rm"

## Executando o nosso cluster.sh

Para executar o cluster, você deve executar o arquivo bash:
```bash
./cluster.sh
```

Caso o cluster não esteja executando, você pode tentar mudar as permissões do arquivo:
```bash
chmod +x cluster.sh
```

Obs: O comando só será executado em um node caso seja executado nos dois. Se um arquivo não puder ser exluído no node1, ele não será excluído em nenhum node.

Ao executar o cluster, irá aparecer uma linha com a informação "Digite um comando: ", agora você tem sete opções de comandos para executar.
- mostrar: Para executar a funcionalidade "mostrar", rode um comando com essa estrutura:
    ```bash
    mostrar /caminho/para/o/arquivo
    ```
- copiar: Para executar a funcionalidade "copiar", rode um comando com essa estrutura:
    ```bash
    copiar /caminho/de/origem/para/o/arquivo/ /caminho/de/destino/para/o/arquivo
    ```
- mover: Para executar a funcionalidade "mover", rode um comando com essa estrutura:
    ```bash
    mover /caminho/de/origem/para/o/arquivo/ /caminho/de/destino/para/o/arquivo
    ```
- definir_permissoes: Para executar a funcionalidade "definir_permissoes", rode um comando com essa estrutura:
    ```bash
    definir_permissoes chmod +x /caminho/para/o/arquivo
    ```
- criar_usuario: Para executar a funcionalidade "criar_usuario", rode um comando com essa estrutura:
    ```bash
    criar_usuario seu_nome
    ```
- criar_grupo: Para executar a funcionalidade "criar_grupo", rode um comando com essa estrutura:
    ```bash
    criar_grupo seu_grupo
    ```
- deletar: Para executar a funcionalidade "deletar", rode um comando com essa estrutura:
    ```bash
    deletar /caminho/para/o/arquivo
    ```

## Integrantes do grupo:
- 222116281, Landerson E Miranda
- 222116288, Wellington Miguel de Jesus Silva 
- 222116306, Carlos Eduardo Lima Botelho Vasconcelos 
- 222116286, Ryan Reis dos Santos
