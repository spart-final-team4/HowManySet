//
//  MembershipView.swift
//  HowManySet
//
//  Created by MJ on 12/2/25.
//

import SwiftUI
import UIKit

class MembershipViewHostingController: UIHostingController<MembershipView> {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

struct MembershipView: View {
    
    private let membershipDescription: String = """
        
        HowManySet 회원전환 페이지입니다.
        
        """
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            VStack {
                Text("HowManySet 회원전환")
                    .font(.largeTitle)
                    .bold()
                Text(membershipDescription)
                signUpWithSocial(.kakao) {
                    
                }
                signUpWithSocial(.google) {
                    
                }
                signUpWithSocial(.apple) {
                    
                }

                    
            }
        }
    }
    
    private func signUpWithSocial(_ type: SocialType,
                                  action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Image(type.imageResoure)
                Text(type.bannerTitle)
                    .font(.title3)
                    .foregroundStyle(type.titleColor)
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(type.backgroundColor)
            )
            .padding(.horizontal, 20)
        }
    }
    
}

private extension MembershipView {
    enum SocialType {
        case apple
        case kakao
        case google
        
        var bannerTitle: String {
            switch self {
            case .apple:
                "Apple로 로그인"
            case .kakao:
                "Kakao로 시작하기"
            case .google:
                "Google로 로그인"
            }
        }
        
        var imageResoure: ImageResource {
            switch self {
            case .apple:
                    .apple
            case .kakao:
                    .kakao
            case .google:
                    .google
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .apple:
                return .black
            case .kakao:
                return Color(uiColor: UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0))
            case .google:
                return .white
            }
        }
        
        var titleColor: Color {
            switch self {
            case .apple:
                return .white
            case .kakao:
                return .black
            case .google:
                return .black
            }
        }
    }
}

#Preview {
    MembershipView()
}
