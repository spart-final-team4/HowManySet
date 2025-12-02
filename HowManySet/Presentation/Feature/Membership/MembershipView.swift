//
//  MembershipView.swift
//  HowManySet
//
//  Created by MJ on 12/2/25.
//

import SwiftUI

struct MembershipView: View {
    
    private let membershipDescription: String =
        """
        HowManySet 회원전환 페이지입니다.
        아래 주의사항을 읽고 회원전환을 진행해주세요.
        
        1. 비회원 전환 시 저장된 정보가 로그인된 회원 정보로 이전됩니다.
        2. 회원 정보가 이전되면서 기존의 비회원 정보들이 일괄 삭제됩니다.
        3. 회원으로 전환하여도 비회원으로 앱을 이용할 수 있습니다.
        
        """
    
    var dismiss: (() -> Void)?
    var signUpWithKakao: (() -> Void)?
    var signUpWithGoogle: (() -> Void)?
    var signUpWithApple: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            VStack {
                Button {
                    dismiss?()
                } label: {
                    Image(.iconX)
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .padding(EdgeInsets(top: 40, leading: 0, bottom: 20, trailing: 0))
                
                
                Text("HowManySet 회원전환")
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .bold()
                Text(membershipDescription)
                    .foregroundStyle(.white)
                    .padding()
                Spacer()
                
                VStack(spacing: 10) {
                    signUpWithSocial(.kakao) { signUpWithKakao?() }
                    signUpWithSocial(.google) { signUpWithGoogle?() }
                    signUpWithSocial(.apple) { signUpWithApple?() }
                }
                .padding()
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
