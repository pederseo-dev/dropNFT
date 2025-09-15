// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Pixel Vending Machine (MVP en L2)
/// @notice Cola de imágenes 32x32 donde se venden píxeles como NFTs secuenciales

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PixelMachine is ERC721, Ownable {
    // -------------------------------
    // Estructuras de datos
    // -------------------------------
    struct Image {
        bytes32 hash;        // Hash de la imagen (off-chain)
        uint256 totalPixels; // Siempre 1024 (32x32)
        uint256 soldPixels;  // Contador de píxeles vendidos
        address artist;      // Artista que subió la imagen
    }

    Image[] public queue;        // Cola de imágenes
    uint256 public currentImage; // Índice de la imagen activa

    // Asociación pixel -> comprador (opcional para consultas rápidas)
    mapping(uint256 => mapping(uint256 => address)) public pixelOwner;

    // Comprador actual y anterior (para tracking rápido)
    address public lastBuyer;
    address public previousBuyer;

    // -------------------------------
    // Configuración económica
    // -------------------------------
    uint256 public feeAddImage = 0.001 ether;   // costo por agregar imagen
    uint256 public pricePerPixel = 0.001 ether; // costo por pixel
    uint256 public ownerCut = 500;              // fee dueño (500 = 5%)
    uint256 public constant DENOMINATOR = 10000;

    // -------------------------------
    // Eventos
    // -------------------------------
    event ImageAdded(uint256 indexed imageId, bytes32 hash, address indexed artist);
    event PixelBought(
        uint256 indexed imageId,
        uint256 indexed pixelIndex,
        uint256 tokenId,
        address indexed buyer,
        address artist
    );

    // -------------------------------
    // Constructor
    // -------------------------------
    constructor() ERC721("PixelMachine", "PMCH") Ownable(msg.sender) {
        // ERC721 se inicializa con nombre y símbolo
        // Ownable recibe la dirección del owner inicial
    }

    // -------------------------------
    // Funciones principales
    // -------------------------------

    /// @notice Agregar nueva imagen a la cola
    function addImage(bytes32 hash) external payable {
        require(msg.value >= feeAddImage, "Pago insuficiente");

        // Guardar imagen (siempre 1024 px en este MVP)
        queue.push(Image({
            hash: hash,
            totalPixels: 1024,
            soldPixels: 0,
            artist: msg.sender
        }));

        // Fee dueño
        uint256 fee = (msg.value * ownerCut) / DENOMINATOR;
        payable(owner()).transfer(fee);

        emit ImageAdded(queue.length - 1, hash, msg.sender);
    }

    /// @notice Comprar siguiente pixel disponible de la imagen activa
    function buyPixel() external payable {
        require(queue.length > 0, "No hay imagenes");
        Image storage img = queue[currentImage];
        require(img.soldPixels < img.totalPixels, "Imagen agotada");
        require(msg.value >= pricePerPixel, "Pago insuficiente");

        // Índice del pixel que toca (secuencial)
        uint256 pixelIndex = img.soldPixels;

        // Registrar dueño en mapping
        pixelOwner[currentImage][pixelIndex] = msg.sender;

        // Actualizar contador
        img.soldPixels++;

        // Actualizar historial rápido de compradores
        previousBuyer = lastBuyer;
        lastBuyer = msg.sender;

        // Generar tokenId único: imageId * 10000 + pixelIndex
        uint256 tokenId = currentImage * 10000 + pixelIndex;
        _mint(msg.sender, tokenId);

        // Distribución de pago
        uint256 fee = (msg.value * ownerCut) / DENOMINATOR;
        uint256 artistShare = msg.value - fee;
        payable(owner()).transfer(fee);
        payable(img.artist).transfer(artistShare);

        emit PixelBought(currentImage, pixelIndex, tokenId, msg.sender, img.artist);

        // Si la imagen ya terminó → pasar a la siguiente
        if (img.soldPixels == img.totalPixels && currentImage < queue.length - 1) {
            currentImage++;
        }
    }

    // -------------------------------
    // Helpers
    // -------------------------------

    /// @notice Total de imágenes en cola
    function totalImages() external view returns (uint256) {
        return queue.length;
    }
}
