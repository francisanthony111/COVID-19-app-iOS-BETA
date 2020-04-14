//
//  SubmitSymptomsViewControllerTests.swift
//  CoLocateTests
//
//  Created by NHSX.
//  Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import CoLocate

class SubmitSymptomsViewControllerTests: TestCase {

    func testNotRegistered() {
        // TODO
    }
    
    func testSubmitTapped() {
        let registration: Registration = Registration.fake
        let persistenceDouble = PersistenceDouble(registration: registration)

        let contactEventRepository = MockContactEventRepository(contactEvents: [ContactEvent(sonarId: Data())])

        var actualRegistration: Registration?
        var actualContactEvents: [ContactEvent]?

        let vc = SubmitSymptomsViewController.instantiate()
        XCTAssertNotNil(vc.view)
        vc._inject(
            persistence: persistenceDouble,
            contactEventRepository: contactEventRepository,
            sendContactEvents: { registration, contactEvents, _ in
                actualRegistration = registration
                actualContactEvents = contactEvents
            }
        )
        vc.hasHighTemperature = false
        vc.hasNewCough = true

        let unwinder = SelfDiagnosisUnwinder()
        parentViewControllerForTests.viewControllers = [unwinder]
        unwinder.present(vc, animated: false)

        let button = PrimaryButton()
        vc.submitTapped(button)

        XCTAssertFalse(button.isEnabled)
        XCTAssertEqual(actualRegistration, registration)
        XCTAssertEqual(actualContactEvents, contactEventRepository.contactEvents)
    }

    func testSubmitSuccess() {
        let persistenceDouble = PersistenceDouble(registration: Registration.fake)
        let contactEventRepository = MockContactEventRepository(contactEvents: [ContactEvent(sonarId: Data())])

        var completion: ((Result<Void, Error>) -> Void)?

        let vc = SubmitSymptomsViewController.instantiate()
        XCTAssertNotNil(vc.view)
        vc._inject(
            persistence: persistenceDouble,
            contactEventRepository: contactEventRepository,
            sendContactEvents: { completion = $2 }
        )
        vc.hasHighTemperature = false
        vc.hasNewCough = true

        let unwinder = SelfDiagnosisUnwinder()
        parentViewControllerForTests.viewControllers = [unwinder]
        unwinder.present(vc, animated: false)

        let button = PrimaryButton()
        vc.submitTapped(button)

        XCTAssertNotNil(completion)

        completion?(.success(()))
        
        XCTAssertTrue(contactEventRepository.hasReset)
        XCTAssertTrue(button.isEnabled)
        XCTAssertTrue(unwinder.didUnwindFromSelfDiagnosis)
    }

    func testSubmitFailure() {
        let persistenceDouble = PersistenceDouble(registration: Registration.fake)
        let contactEventRepository = MockContactEventRepository(contactEvents: [ContactEvent(sonarId: Data())])

        var completion: ((Result<Void, Error>) -> Void)?

        let vc = SubmitSymptomsViewController.instantiate()
        XCTAssertNotNil(vc.view)
        vc._inject(
            persistence: persistenceDouble,
            contactEventRepository: contactEventRepository,
            sendContactEvents: { completion = $2 }
        )
        vc.hasHighTemperature = false
        vc.hasNewCough = true

        let unwinder = SelfDiagnosisUnwinder()
        parentViewControllerForTests.viewControllers = [unwinder]
        unwinder.present(vc, animated: false)

        let button = PrimaryButton()
        vc.submitTapped(button)

        XCTAssertNotNil(completion)


        // TODO: Fill in with the expected behavior - this currently panics.
//        completion?(.failure(FakeError.fake))
//
//        XCTAssertTrue(button.isEnabled)
    }

}


class SelfDiagnosisUnwinder: UIViewController {
    var didUnwindFromSelfDiagnosis = false
    @IBAction func unwindFromSelfDiagnosis(unwindSegue: UIStoryboardSegue) {
        didUnwindFromSelfDiagnosis = true
    }
}

class MockContactEventRepository: ContactEventRepository {
    var contactEvents: [ContactEvent] = []
    var hasReset: Bool = false
    
    init(contactEvents: [ContactEvent]) {
        self.contactEvents = contactEvents
    }
    
    func reset() {
        hasReset = true
    }
}
