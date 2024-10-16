# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs


# Схема архитектуры

[Ссылка на схему](https://app.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=task1.drawio#R%3Cmxfile%3E%3Cdiagram%20name%3D%22Page-1%22%20id%3D%22-H_mtQnk-PTXWXPvYvuk%22%3E7V1Jd9s4Ev41PiqPALgevSSZ7unM5HWS6c4pj5ZoiRNZVFP01r%2B%2BQXGRiIJFWCaBIuUcYguSaLK%2BQu1VOGOXt48f03C9%2BJTMouUZtWaPZ%2BzqjFLbYh7%2Fka88FSvUIU6xMk%2FjWbFGdgtf4r%2BjctEqV%2B%2FiWbRpfDBLkmUWr5uL02S1iqZZYy1M0%2BSh%2BbGbZNn8q%2BtwHoGFL9NwCVf%2FiGfZolwlbrB7419RPF%2BUf9qn5RPfhtWHyyfZLMJZ8rC3xN6fscs0SbLit9vHy2iZU6%2BiS%2FG9D8%2B8W99YGq0ylS%2F8fU7Zp%2BTrt83XD%2FaPgGT%2BffxtQour3IfLu%2FKBPyWreXJ1Ud5z9lQRgt%2F%2BOv91%2BrSMV7MoZWfs4mERZ9GXdTjN33jgHMDXFtntkr8i%2FNfr5I5%2Fcvbbdb0QTn%2FO03z1v3cZv0xUrm8K2DlrsAv4WOWT3kdpFj3uLZWP%2BTFKbqMsfeIfKd%2BdOKykecl1zClfP%2BwgdMulxT545VpYMs28vvSOrvyXkrQvIDMDZF4%2F3eaEnoTrGJA6LehWEqeFyF3Qy%2Faa9KIWpBehEoK5HRDMIv%2FbrL4vsnD9yUn%2B%2FOtP%2F%2BOHmwkBBBsDXzLHMcaXUjJTQM5oxsVf%2BTJJs0UyT1bh8v1u9WLHnRZ%2FtfvMb0myLun2%2FyjLnkpZHt5lSZP80WOc%2FZl%2F%2FZ1Tvvq%2B987VY3nl7Yun6sWKP%2B7el%2FKX3%2Fff231t%2B6rxvc9RGnN6RWm5%2BCyUm%2BQunUbt%2BzgL03mUtYvVnJgHGSONlmEW3zd1TecoszeUX4vyISGFBWUXyMwz6i75A1zcJJwE%2Bwzg%2FnWXVG9MCil3zj%2FA3PXjlnLV%2B%2Fy3ef6TVFfid1ZcrFgHjMUlYdbkg3AZz1e5fOYw5Nhc5PIy5gbWefnGbTybbVlOJrWbbNiJrrObuq7Way0ymPUlgysTuQ%2Fc6GhwI0ETNkXN2RtqLjTpOkONjQc1wpDtNteW4CaQNb7dOoUXm59RNl2U1Ag368K%2FvIkfcxLtU32dxKtse6fOxZlzJcMhx7HUlYQT7KL8G1fx7Zw%2FxzK%2Bzp9mMw0j%2FvMynC6iH79Hs3jz43OazO6m2bvN%2FbwjSJhg7BPJVnIkkNi0L0gcAMn22Ttl9zTiGy%2B83l7KkkPGTZjK4M%2FBz9LkZ3SZLJPcoFgluVNwcRMvl8JSL5BIdokMki52yc9vd1%2FuI8f6ZfPr7%2BRX21%2F%2FO4gmnjt0k5G0mIyzcLOoXWypHddqO0opR2xoPEo%2FaOsyFg%2Fe5iExeEQYAvC8hIjPbgPfau6C2lLb2wWMSbYB9fraBwSKJhxxiFcROhCUsq0xDCEn8%2BDFTZuH%2BoyEaRcnnqo4cZS5QI%2BEsY1iSvYQ3eErx7RL6S%2BB64AZakz6Q5ez43j0q%2BQTscR4NIECqrd4tJxiwRgVge8ITnVgWBFUmI6LzMRi2OhMAZ3TaL3knhNfJIDWOuIMnTKy6%2BkLM8gJDMNDOwJDUxs9gQELm6ewY9K%2BeJHNyF%2BIyYkeMh1HGJcOtFYOaj80xiUdjsMwePArnYwHfM8k%2BC%2FxLPoMTrUCTH1FgG11baAJYB8oT4C4dp%2BECLUbCKJTdJROCeHWXJPSpsNTbJxeCUipmvZKGPRKxkBnJvCzeTrD4P%2BgvT%2FAycadEwbzBsN2%2F0QeNk%2FhNw%2FgtR5AZT60GoiVXEZjIDL%2FDXxt4GNz%2Fxi0erk1kM4m3WqungtGXhmNE1PlkgSJVnFsQxO5AKVbZYcaFEodZKDALorLZHUTz3NAopQ%2FLQBHu1ttu01OrilkLNVnQ5bVqVw6CC%2F1VYxgK8eLbWQ6wzbaAtFFyNA4plVQDg%2Bm9vAwbSC6A7jPMLAywOjCwLakLji5yzBoLbFAhelsmJRX7A4nHXpkUuSZDXBMmZatmhrxLDkfaNoACPMgk5qtD1i5mvMg9jjzIAKdFTtneosaV1mY4UqYvmwoh6qKE2x2cXXnWAtBhbIu4ptWsw6s6xqBqJkI5owjccL1yhqYoRoBmQnBRuZDaaoBJgJFPnYlNRpaI3AO7Mkfdh6QYCOw0VqwUWSCKuu51XqpdB8e6%2BUtDagPfHSma2ASfB1VoMdiWglgxegGIkyrO8cU8KCsPaunOd7hYp2O9ipCM1cgtOmAhwud4xGQmWLz9SSTdEZAZlvgZvNkHlnRp8jHxl0RyRibQft6IgebJ%2FBbyedrzf3Kcmg1DV1svp775ujrA59iAx8mQk%2Bt5NNvajsmyYToFcbPVeF2q%2BkwQ8IsBxcmHnSfsdV7OsL01ZoY5gpnoAx5K%2FdsZKvbK8ewlQZ6UAgNLDZoHNNqv%2BHBdIAlvA1EW8s9e8cUXbzXgzEJLBWeQuUJlfQ7atZTcGbbIgqX%2FGZOxd4iVOgV8STGg16DCxrBAA3sw6RfmRwRGtF0DpOWQuJDG3hww6RfCYkQtyNVEYqpYdK%2BWQsbyTDpVjXuU0U1Tixsufjq1jHlbYknTjmWaAvNiVt%2FlKku4gt6WTYaSWuuyzfaGoa5VN13lYUMNqeemJ76QHEokmMantRhL6pdjCkSWC%2BLqR%2BBis1PgQMEnV6v0Ide4Rg0iiekOxzF0Hp%2FGgVmoMZA58DFRmfoUQ%2B6SgVwsqtYB9SbNxZAB3nQZSqAh81TeDj%2BLtZSBV9yBOdB%2FYfGSg3gFnoDvy%2FwsbkowQBzVAYiXYFqwgpfpCtAeG4atcSByeYjXcEoD07Lg%2BlNSpuOdAXQYR4DnUU%2F27hfEozSz6ZM4GfzdIZ%2B9qD9P8DJ5r2TQx72AP0%2FwMPGKUyqnPibD3C8iag6tS7A5gASiZh6Q78v9F106FMgXk%2BtVYGA84Ul0xE1S2SYeD%2B1bgUKDjAyjwp0prH1K1AmHC1CJQVumo%2BitcyO%2BuwgytRXdUNdtNAeOqToFMdgzsvGi2qALVxIrAGeVdjAVM%2BQanWI8YWE63vH18VAxXNCqOToMd3aC8YfTqyPgYrHlXmKk276s8SI0cTVS3zWZyTMMUVx5TDDV8iN8qufc%2Bba33VO8C7Y%2ByffgtUFC5FXXkMAsr6p15RNGp6cMOCyyXrcJfa6yfpGkRZOkkAogzJeOEkIdP2RiryO7e3jNoLq7JDSGjK2EQyfC9mBG2VO2CljbFrYEdzCzmfohB2i0VmW8q7glkvDFbW4bDkiC2F%2BwxR9wsb2C4X5yF4k3gDUmHKYgZiNKdSPhGDDanTI1OHpxHU7T9Pwae8DZZTggGcnSPZJubV2WBeX7NaDo9BU7SVEOKL9WzSSGdu%2Bttnt24EV2oZqf0pVWQaYtkJh2Pf88y984eP51%2Fd%2FnH83b4eKTvfE%2BPFJhMJE%2FJYsOWzJdbwCRBttENgSJ%2BFBbHytMWBGATRQiK1mXMElDztSNOTAHkpNYbYzLDx1V6BTqfKMvdAyE6Vae3VEWLAb6nhddY3iCUAQWHIlYey1WInbezQZbuDRcMlzRoMmJhFPfBQTBco8Il5IO4%2FAup5pPoXqdIS7OKmsmpBpLMHHYD%2FOlyi9j%2Fl%2BoNZVvJkm%2FIGfzJssrid3sAyaLExWMD%2BPN9sE%2F7ZObUvFE2Ft4gnChXiQt%2BsKeD3MXQ2T20MoXud%2FaZZyUm62ojlL4%2Bg%2BXs1PCChHwfqXdQX2CJTMeHCXOf3zkYYNYNy%2F7pLqjUlBwnP%2BAeauH7cEqt7nv83zn3Z1JX5rxcWK9U4B19PRYglbbEIk00f16g9boe911JMuGRMauYikzUjrpEtiQ51%2BWqMuGRMan4lreNQlsREl2szV2rT743ZZlNQe5asOmsBT72nDXmAAuvZKT1HbyzrTNc8AIPYoh2ZRXwir2pKWEK1N06Q6xXW4Uqe33gFHuajFw3bkVT1L%2B1QqN%2FethDPKZmHk30yBScHfcad%2BdH2jhy0CdQGhiy1wlz8xImQ26oY1czEcB0YIRqGJhPYOR9LeoVcTOaOccE3FTCoCQo%2FtOFeRl13jMQ9nZAe6Ai5GQOLhuMtYZ2XUXla7KVNpQUSmzNuprjrxx%2BfhGB3p30XTu55wmROoYowvXFbdO6ZwGSNW%2ByBH3eGySvWOy3ZmlAmkNh4uc6EDPQZCi363eSelOkh8ZIRmAkcjILSkrHbI3iDgZfOuinvI4R6gNwi4GAGJzQ62GoU3UCGmYCmi8wbdt2iATvzRJTZcmFg%2FtdmZNBDz%2BMS4VIZZ%2FFObncmI52BDBXrV2GZnMluoY6SSkjnNicDKxhlvY%2BbRmsNTPXanLoDCozk8o%2F22XcQREcDqoAsdelDFoIe1Aaqm6ZnqGOMLD3swdIFkeiazhJJvJpmYrVt%2FwSjEiU3PZGJ3oyc57UqvLeYNJm5xvITpQeWXXxW6V5nlHZieWW9BXb2snuGYxIhrMD3lHgB8NZgeDFWgqsEUBz8jqMH0jOb6URep%2B8pBO3xF6p7Z3oMOXC%2Bs8lGdK%2FDJx%2BrekcpH6jvo5KNvdmYYohmd4h5zIn9my%2FaYT6%2BZ6%2BrZYza6cyeqM2xGNdZTATJXFbIKXESQDf2chS7h6c2nfOlYT2aJozLKEEO%2FYz19u7%2F9S8awfx18Zs3oj17rJiCtjjFC0xUeqY5rridw7ieSyi3dxiuMh5zmXE9muWLSAGCjd66nD%2Bs3oBDTObFRo3n%2FAhNDz5BHYGrU%2B%2FSlUx6ZJZwipvtcKV%2Bhr2OsfPUCy0QTX1FxwqyYKFHmK%2FFKuvkqgKGj05oeyqjYbW56emhlpCGfHkrdQO7HGTSMAgoNo9OdHrpL1ldiyjc%2BPTSABShv00OpJw7ilfkYeqeHBrIZlB1ND3VGMz2UgTNqmGLDZW%2FIcbpLkHveVJwuw80mnh4yEF%2BehjvqwBJT5hx1bfquWXLu%2BeSdJ1xIeSK8R1Uu17NlRy04UOWMo3nB%2Fydn%2FsX2d2%2F7%2F%2FvGOrVUrI3nd%2BYyusmGK4gdT4Su6pPZF8WaNzSMkXW8odudt6FvaJ%2BQd5UP3cGGll2u9w0tCS2pbejTGlRMPRts4kCyibUavvWJQyhKG9UrDvazGW2lO6piQSHmQ0lpfrbmNCgxevjc7pEM4fqCkN3AcDV6tHV9oyoz%2BMHY%2FfVewQ3%2FY%2FF6E%2B3V4BwUuZtFONuq8UZ%2BMH%2Bx4b4M94q%2Fblkkn9ghG88fTnPa%2FJjFKb%2BjJCfEh4fo%2BkfRpNjhgH5XLHmlAZCw9gEN3wNgkkN3CnYsLFpJj8tYNSBzhHhCHRgzqP8QtW0oikmyLyTbu8s6FZOqKX1anPFoTkxC3%2BTy6j8Aav3d0GJEjUh2gNbgNCUwa%2F97NI%2BT1VnXU4NQyyZbSNlPJMPgPL2iCdEklAGIJtUJmMZFE%2FSXUYgmF9Q%2FmhdNsLrgFEWTa6MTTRQAA%2BAYhhdyt%2BnU%2F6DV6XYVVFQyFpD4VRxIjwtCYY0x0oLzjuuQj1IkVHmOwnNHBesK8UiGJkScxfnSr1%2FM65Pauau3Qo%2BFGPxlmuTJ3F1omz%2FU4lMyi%2FJP%2FAM%3D%3C%2Fdiagram%3E%3C%2Fmxfile%3E)

# Реализация

## Как запустить

Перейти в папку sharding-repl-cache

Запустить команду

```shell
docker compose up --build -d
```

Инициализация конфиг сервера:

```shell
docker exec -it configSrv mongosh --port 27020

> rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27020" }
    ]
  }
);
> exit();
```

Инициализация шардов:

```shell
docker exec -it shard1 mongosh --port 27021

> rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27021" },
        { _id : 1, host: "mongodb1:27017" },
        { _id : 2, host: "mongodb2:27018" }
      ]
    }
);
> exit();

docker exec -it shard2 mongosh --port 27022

> rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 0, host : "shard2:27022" },
        { _id : 1, host: "mongodb3:27019" },
        { _id : 2, host: "mongodb4:27016" }
      ]
    }
  );
> exit();
```

Инициализация роутера и наполнение тестовыми данными:

```shell
docker exec -it mongos_router mongosh --port 27023

> sh.addShard( "shard1/shard1:27021");
> sh.addShard( "shard2/shard2:27022");

> sh.enableSharding("somedb");
> sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

> use somedb

> for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})

> db.helloDoc.countDocuments() 
> exit(); 
```

Проверка данных на шардах:

```shell
 docker exec -it shard1 mongosh --port 27021
 > use somedb;
 > db.helloDoc.countDocuments();
 > exit(); 

 docker exec -it shard2 mongosh --port 27022
 > use somedb;
 > db.helloDoc.countDocuments();
 > exit(); 
```