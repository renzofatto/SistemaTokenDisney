//SPDX-License-Identifier: MIT
pragma solidity >0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import"./ERC20.sol";

contract Disney{
    //------------------------- DECLARACIONES INICIALES -------------------------
    //0x6DF2d05926a10d418665927Ddd11F5549E1d775f
    
    //Instancia del contrato token
    ERC20Basic private token;
    
    //Direccion de Disney (owner)
    address payable public owner;
    
    //Constructor
    constructor()public{
        token = new ERC20Basic(10000);
        owner = msg.sender;
    }
    
    //Estructura de datos para almacenar a los clientes de Disney
    struct cliente{
        uint tokens_comprados;
        string[] atracciones_disfrutadas;
    }
    
    // Mapping para el registro de clientes
    mapping (address => cliente) public Clientes;
    
    //------------------------- Gestion de Tokens  -------------------------
    
    // Funcion para establecer el precio de un token 
    function PrecioTokens (uint _numTokens) internal pure returns(uint){
        //Conversion de tokens a Ether: 1 Token = 1 ether
        return _numTokens*(1 ether);
    }
    
    // Funcion para comprar Tokens en Disney y usar atracciones 
    function CompraTokens(uint _numTokens) public payable{
        //Establecer el precio de los Tokens
        uint coste = PrecioTokens(_numTokens);
        //Se evalua el dinero que el cliente paga por los Tokens
        require(msg.value >= coste, "Compra menos Tokens o paga con mas ethers.");
        //Diferencia de lo que el cliente paga
        uint returnValue = msg.value - coste;
        //Disney retorna la cantidad de ether al cliente
        msg.sender.transfer(returnValue);
        //Obtencion del numero de tokens disponibles
        uint Balance = balanceOf();
        require(_numTokens<= Balance, "Compra un numero menor de Tokens");
        //Se transfiere el numero de Tokens al cliente
        token.transfer(msg.sender, _numTokens);
        //Registro de tokens tokens comprados
        Clientes[msg.sender].tokens_comprados += _numTokens;
    }
    
    //Balance de tokens del contrato Disney
    function balanceOf() public view returns (uint){
        return token.balanceOf(address(this));
    }
    
    //Visualizar el numero de tokens restantes de un Cliente
    function MisTokens() public view returns (uint){
        return token.balanceOf(msg.sender);
    }
    
    //Funcion para generar mas tokens
    function GeneraTokens (uint _numTokens) public Unicamente(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }
    
    //Modificador para controlar las funciones ejecutables por Disney
    modifier Unicamente(address _direccion){
        require (_direccion == owner, "No tienes permisos para ejecutar esta funcion.");
        _;
    }
    
    //------------------------- Gestion de Disney  -------------------------
    
    // Eventos
    event disfruta_atraccion(string, uint, address);
    event disfruta_comida(string, uint, address);
    event nueva_atraccion(string, uint);
    event nueva_comida(string, uint);
    event baja_atraccion(string);
    event baja_comida(string);
    event alta_atraccion(string);
    event alta_comida(string);
    
    //Estrucura de la atraccion
    struct atraccion{
        string nombre_atraccion;
        uint precio_atraccion;
        bool estado_atraccion;
    }
    //Estructura de la comida
    struct comida{
        string nombre_comida;
        uint precio_comida;
        bool estado_comida;
    }
    
    
    //mapping para relacion un nombre de una atraccion con una estructura de datos de la atraccion
    mapping (string => atraccion) public MappingAtracciones;
    
    //mapping para relacion un nombre de una coimida con una estructura de datos de la comida
    mapping (string => comida) public MappingComidas;
    
    // Array para almacenar el nombre de las atracciones
    string[] Atracciones;
    
    // Array para almacenar el nombre de las comidas
    string[] Comidas;   
    
    //Mapping para relacionar una identidad de un cliente con su historial en Disney
    mapping (address => string[]) HistorialAtracciones;
    
    //Mapping para relacionar una identidad de un cliente con su historial en Disney
    mapping (address => string[]) HistorialComidas;
    
    //Crear nuevas atracciones para Disney (Solo es ejecutable por Disney)
    function NuevaAtraccion (string memory _nombreAtraccion, uint _precio) public Unicamente(msg.sender){
        //Creacion de una atraccion en Disney
        MappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, true);
        //Almacenar en un array el nombre de la atraccion 
        Atracciones.push(_nombreAtraccion);
        //Emision del evento para la nueva Atracciones
        emit nueva_atraccion(_nombreAtraccion, _precio);
    }
    
    //Crear nuevos menus para la comida en Disney(Solo es ejecutable por Disney)
    function NuevaComida (string memory _nombreComida, uint _precio) public Unicamente(msg.sender){
        //Creacion de una comida en Disney
        MappingComidas[_nombreComida] = comida(_nombreComida, _precio, true);
        //Almacenar en un array el nombre de la comida 
        Comidas.push(_nombreComida);
        //Emision del evento para la nueva Comida
        emit nueva_comida(_nombreComida, _precio);
    }
    
    //Dar de baja atracciones en Disney
    function BajaAtraccion(string memory _nombreAtraccion)public Unicamente(msg.sender){
        //El estado de la atraccion pasa a False cuando no esta en uso
        MappingAtracciones[_nombreAtraccion].estado_atraccion = false;
        //Emision del evento para baja de la atraccion
        emit baja_atraccion(_nombreAtraccion);
    }
    
    //Dar de baja comida en Disney
    function BajaComida(string memory _nombreComida)public Unicamente(msg.sender){
        //El estado de la comida pasa a False cuando no esta en uso
        MappingComidas[_nombreComida].estado_comida = false;
        //Emision del evento para baja de la comida
        emit baja_comida(_nombreComida);
    }
    
    //Dar de alta atracciones en Disney
    function AltaAtraccion(string memory _nombreAtraccion)public Unicamente(msg.sender){
        //El estado de la atraccion pasa a True cuando en uso
        MappingAtracciones[_nombreAtraccion].estado_atraccion = true;
        //Emision del evento para alta de la atraccion
        emit alta_atraccion(_nombreAtraccion);
    }
    
    //Dar de alta comida en Disney
    function AltaComida(string memory _nombreComida)public Unicamente(msg.sender){
        //El estado de la comida pasa a True cuando en uso
        MappingComidas[_nombreComida].estado_comida = true;
        //Emision del evento para el alta de la comida
        emit alta_comida(_nombreComida);
    }
    
    // Visualizar las atracciones de Disney
    function AtraccionesDisponibles()public view returns(string[] memory){
        return Atracciones;
    }
    
    // Visualizar las comidas de Disney
    function ComidasDisponibles()public view returns(string[] memory){
        return Comidas;
    }
    
    //Funcion para subirse a una atraccion de Disney y pagar en tokens esa atraccion
    function SubirseAtraccion (string memory _nombreAtraccion) public{
        //Precio de la atraccion en tokens
        uint tokens_atraccion = MappingAtracciones[_nombreAtraccion].precio_atraccion;
        // Verifica el estado de la atraccion, si esta disponible para su uso
        require (MappingAtracciones[_nombreAtraccion].estado_atraccion == true,
                    "La atraccion no esta disponible en estos momentos.");
        //Verificar el numero de tokens que tiene el cliente para subirse a la atraccion
        require(tokens_atraccion <= MisTokens(), 
                    "Necesitas mas tokens para subirte a esta atraccion.");
        /* El cliente paga la atraccion en tokens:
        -Ha sido necesario crear una funcion en ERC20.sol con el nombre "transferencia_disney"
        debido a que en caso de usar el transfr o Transfer from las direccion que se agarraban 
        para realizar la transaccion eran equivocadas. Ya que msg.sender que recibia el metodo Transfer
        era la direccion del contrato.
        */
        token.transferencia_disney(msg.sender,address(this), tokens_atraccion);
        //Almacenamiento en el historial de atracciones del cliente
        HistorialAtracciones[msg.sender].push(_nombreAtraccion);
        //Emitir del evento de uso de la atracciones
        emit disfruta_atraccion(_nombreAtraccion, tokens_atraccion, msg.sender);
    } 
    
    //Funcion para comer una comida de Disney y pagar en tokens esa comida
    function ComerComida (string memory _nombrecomida) public{
        //Precio de la comida en tokens
        uint tokens_comida = MappingComidas[_nombrecomida].precio_comida;
        // Verifica el estado de la comida, si esta disponible
        require (MappingComidas[_nombrecomida].estado_comida == true,
                    "La comida no esta disponible en estos momentos.");
        //Verificar el numero de tokens que tiene el cliente para comer la comida
        require(tokens_comida <= MisTokens(), 
                    "Necesitas mas tokens para comer esta comida.");
        /* El cliente paga la comida en tokens:
        -Ha sido necesario crear una funcion en ERC20.sol con el nombre "transferencia_disney"
        debido a que en caso de usar el transfr o Transfer from las direccion que se agarraban 
        para realizar la transaccion eran equivocadas. Ya que msg.sender que recibia el metodo Transfer
        era la direccion del contrato.
        */
        token.transferencia_disney(msg.sender,address(this), tokens_comida);
        //Almacenamiento en el historial de comidas del cliente
        HistorialComidas[msg.sender].push(_nombrecomida);
        //Emitir del evento de uso de la comida
        emit disfruta_comida(_nombrecomida, tokens_comida, msg.sender);
    } 
    
    //Visualizar el historial de atracciones disfrutadas por un cliente
    function HistorialAtraccion() public view returns (string[] memory){
        return HistorialAtracciones[msg.sender];
    }
    //Visualizar el historial de comidas disfrutadas por un cliente
    function HistorialComida() public view returns (string[] memory){
        return HistorialComidas[msg.sender];
    }
    
    //Funcion para que un cliente de Disney pueda devolver tokens_atraccion
    function DevolverTokens (uint _numTokens) public payable{
        //El numero de token a devolver es positivo
        require (_numTokens>0, "Necesitas devolver una cantidad positiva de tokens");
        //El usuario debe tener el numero de tokens que desea devolver
        require(_numTokens <= MisTokens(), "No tienes los tokens que deseas devolver");
        // EL cliente devuelve los tokens
        token.transferencia_disney(msg.sender, address(this),_numTokens);
        //Disney devuelve los tokens en forma de ether
        msg.sender.transfer(PrecioTokens(_numTokens));
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}