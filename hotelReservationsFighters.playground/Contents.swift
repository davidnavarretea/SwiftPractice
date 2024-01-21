import SwiftUI

struct Client {
    let name: String
    let age: Int
    let height: Int
}

struct Reservation {
    let id: Int
    let hotelName: String
    let clients: [Client]
    let duration: Int
    let price: Double
    let breakfastOption: Bool
}

enum ReservationError: Error {
    case duplicateID
    case clientAlreadyBooked
    case reservationNotFound
}

class HotelReservationManager {
    var reservations : [Reservation] = []
    private var nextReservationID = 1
    private var reservedClientNames: Set<String> = []
    
    func addReservation(clients: [Client], duration: Int, breakfastOption: Bool) throws -> Reservation {
        let id = nextReservationID
        let hotelName = "Hotel Luchadores"
        let basePricePerClient = 20.0
        let breakfastMultiplier = breakfastOption ? 1.25 : 1.0
        let price = Double(clients.count) * basePricePerClient * Double(duration) * breakfastMultiplier
        let newReservation = Reservation(id: id, hotelName: hotelName, clients: clients, duration: duration, price: price, breakfastOption: breakfastOption)
        if reservations.contains(where: { $0.id == id }) {
            throw ReservationError.duplicateID
        }
        for client in clients {
            if reservedClientNames.contains(client.name) {
                throw ReservationError.clientAlreadyBooked
            }
            reservedClientNames.insert(client.name)
        }
        reservations.append(newReservation)
                nextReservationID += 1
                return newReservation
    }
    
    func cancelReservation(id: Int) throws {
        if let i = reservations.firstIndex(where: { $0.id == id }) {
            reservations[i].clients.forEach { reservedClientNames.remove($0.name) }
            reservations.remove(at: i)
        } else {
            throw ReservationError.reservationNotFound
        }
    }
    
    var currentReservations: [Reservation] {
        return reservations
    }
}

func testAddReservation(manager: HotelReservationManager) {
    let client1 = Client(name: "Goku", age: 30, height: 175)
    let client2 = Client(name: "Vegeta", age: 35, height: 165)
    do {
        let reservation1 = try manager.addReservation(clients: [client1], duration: 2, breakfastOption: true)
        print("Reserva añadida: \(reservation1)")
        let reservation2 = try manager.addReservation(clients: [client2], duration: 3, breakfastOption: false)
        print("Reserva añadida: \(reservation2)")
        let reservation3 = try manager.addReservation(clients: [client1], duration: 1, breakfastOption: true)
        print("Reserva añadida: \(reservation3)")
    } catch ReservationError.duplicateID {
        print("Error: ID duplicado.")
    } catch ReservationError.clientAlreadyBooked {
        print("Error: Cliente ya tiene reserva.")
    } catch {
        print("Error desconocido.")
    }
    assert(manager.reservations.count > 0, "Debería haber al menos una reserva.")
}

func testCancelReservation(manager: HotelReservationManager) {
    do {
        try manager.cancelReservation(id: 1)
        print("Reserva con ID 1 cancelada.")
    } catch {
        print("Error al cancelar reserva con ID 1.")
    }
    assert(!manager.reservations.contains(where: { $0.id == 1 }), "La reserva con ID 1 debería haber sido eliminada.")
    var errorCapturado: ReservationError?
    do {
        try manager.cancelReservation(id: 999)
    } catch let error as ReservationError {
        errorCapturado = error
    } catch {
        print("Error inesperado.")
    }
    assert(errorCapturado == .reservationNotFound, "Debería haber capturado un error de 'Reserva no encontrada'.")
}


func testReservationPrice(manager: HotelReservationManager) {
    let client1 = Client(name: "Piccolo", age: 40, height: 200)
    let client2 = Client(name: "Trunks", age: 20, height: 170)
    do {
        let reservation1 = try manager.addReservation(clients: [client1], duration: 3, breakfastOption: true)
        let reservation2 = try manager.addReservation(clients: [client2], duration: 3, breakfastOption: true)
        assert(reservation1.price == reservation2.price, "Los precios deben ser iguales.")
    } catch {
        assertionFailure("No debe ocurrir")
    }
}

let manager = HotelReservationManager()
testAddReservation(manager: manager)
testCancelReservation(manager: manager)
testReservationPrice(manager: manager)
