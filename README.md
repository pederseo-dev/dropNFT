# Máquina Expendedora de NFTs

Esta es una **DApp simple** que permite a los usuarios agregar NFTs a una “máquina” y comprarlos pagando con ETH a través de MetaMask.

## Características

- Conectar tu wallet MetaMask.
- Agregar NFTs a la máquina (con dirección de contrato y token ID).
- Comprar NFTs pagando en ETH.
- Ver la cola de NFTs disponibles.

## Requisitos

- Navegador con **MetaMask** instalado.
- Acceso a la blockchain donde esté desplegado el contrato (por ejemplo, Ethereum o testnet).
- Código del contrato desplegado y ABI disponibles.

## Cómo usar

1. Clona o descarga este repositorio.
2. Abre el archivo `index.html` en tu navegador (puede ser con **Live Server**).
3. Conecta tu wallet con el botón **Conectar MetaMask**.
4. Agrega NFTs usando la sección **Agregar NFT**.
5. Compra NFTs desde la sección **Comprar NFT**.
6. Actualiza la cola de NFTs con el botón **Actualizar**.

## Estilos

- La app utiliza **Tailwind CSS** mediante CDN para estilos rápidos y responsivos.

## Nota

Esta app es **solo frontend**, todo el manejo de NFTs se hace a través del contrato inteligente en la blockchain. No hay backend ni almacenamiento propio.

---
