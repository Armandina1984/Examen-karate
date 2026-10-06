Feature: Regresion

  Scenario: Registro de Usuarios
    * def generarCelular = function(){ return '9' + Math.floor(10000000 + Math.random() * 90000000) }
    * def celularEmisor = generarCelular()
    * def celularReceptor = generarCelular()

    # REGISTRO DEL EMISOR
    Given url 'http://134.209.211.10:4001'
    And path 'auth/v1/register'
    And header x-channel = 'POSTMAN'
    And request
    """
    {
      "phone": "#(celularEmisor)",
      "fullName": "Emisor QA",
      "email": "emisor@test.com",
      "pin": "123456"
    }
    """
    When method post
    Then status 201

    # REGISTRO DEL RECEPTOR
    Given url 'http://134.209.211.10:4001'
    And path 'auth/v1/register'
    And header x-channel = 'POSTMAN'
    And request
    """
    {
      "phone": "#(celularReceptor)",
      "fullName": "Receptor QA",
      "email": "receptor@test.com",
      "pin": "123456"
    }
    """
    When method post
    Then status 201
        # LOGIN DEL EMISOR
    Given url 'http://134.209.211.10:4001'
    And path 'auth/v1/login'
    And header x-channel = 'POSTMAN'
    And request
    """
    {
      "phone": "#(celularEmisor)",
      "pin": "123456"
    }
    """
    When method post
    Then status 200
    * def tokenEmisor = response.token
        # RECARGA DEL EMISOR
    Given url 'http://134.209.211.10:4002'
    And path 'wallet/v1/deposit'
    And header x-channel = 'POSTMAN'
    And header Authorization = 'Bearer ' + tokenEmisor
    And request
    """
    {
      "amount": 1000
    }
    """
    When method post
    Then status 200
    And match response.success == true
    * def saldoInicialEmisor = response.newBalance
        # LOGIN DEL RECEPTOR
    Given url 'http://134.209.211.10:4001'
    And path 'auth/v1/login'
    And header x-channel = 'POSTMAN'
    And request
    """
    {
      "phone": "#(celularReceptor)",
      "pin": "123456"
    }
    """
    When method post
    Then status 200
    * def tokenReceptor = response.token

        # RECARGA DEL RECEPTOR
    Given url 'http://134.209.211.10:4002'
    And path 'wallet/v1/deposit'
    And header x-channel = 'POSTMAN'
    And header Authorization = 'Bearer ' + tokenReceptor
    And request
    """
    {
      "amount": 1000
    }
    """
    When method post
    Then status 200
    And match response.success == true
    * def saldoInicialReceptor = response.newBalance
        # TRANSFERENCIA EMISOR A RECEPTOR
    Given url 'http://134.209.211.10:4003'
    And path 'transaction/v1/transfer'
    And header x-channel = 'POSTMAN'
    And header Authorization = 'Bearer ' + tokenEmisor
    And request
    """
    {
      "recipientId": "#(receptorId)",
      "amount": 450.00,
      "description": "Pago de Servicios",
      "categoryId": "cat_food_1"
    }
    """
    When method post
    Then status 200
    And match response.status == 'COMPLETED'
    * def transactionId = response.transactionId
    * def referenceCode = response.referenceCode
