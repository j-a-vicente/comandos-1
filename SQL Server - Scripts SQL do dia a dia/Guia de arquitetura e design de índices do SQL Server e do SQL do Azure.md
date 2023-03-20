# Guia de arquitetura e design de índices do SQL Server e do SQL do Azure

Os índices criados inadequadamente e a falta de índices são as principais fontes de gargalos do aplicativo de banco de dados. A criação eficiente de índices é muito importante para alcançar um bom desempenho de banco de dados e de aplicativo. Este guia de design de índices contém informações sobre a arquitetura de índices e as melhores práticas para ajudar você a criar índices efetivos de acordo com as necessidades de seu aplicativo.

#### Noções basicas de index.

O uso de índices pode trazer grandes melhorias para o desempenho do banco de dados. Pensando nisso, devemos então, primeiramente, entender como funciona o mecanismo que está trabalhando nos bastidores.

Os registros são armazenados em páginas de dados, páginas estas que compõem o que chamamos de pilha, que por sua vez é uma coleção de páginas de dados que contém os registros de uma tabela. Cada página de dados tem seu tamanho definido em até 8 Kb, apresenta um cabeçalho, também conhecido como header, que contém arquivos de links com outras páginas e identificadores (hash) que ocupam a nona parte do seu tamanho total (8 Kb) e o resto de sua área é destinada aos dados. Quando são formados grupos de oito páginas (64 Kb), chamamos este conjunto de extensão, como mostra a Figura 1.


Os registros de dados não são armazenados em uma ordem específica, e não existe uma ordenação sequente para as páginas de dados. As páginas de dados não estão vinculadas a uma lista, pois implementam diretamente o conceito de pilhas. Quando são inseridos registros em uma página de dados e ela se encontra quase cheia, as páginas de dados são divididas em um link é estabelecido para marcações e ligações entre elas.

#### O que Índece.
Coleção de entradas de dados que suporta a recuperação
eficiente de registros combinando uma certa condição de
pesquisa.

#### Tipo de Índice.


