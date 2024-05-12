#!/bin/bash

source <(curl -sSL https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box_Config_Installer/Source.sh)

while true; do
    user_choice=$(whiptail --clear --title "Main Menu" --menu "Please select a protocol:" 25 50 15 \
        "Optimize" "Optimize Server" \
        "Update" "Update Sing-Box Cores" \
        "" "" \
        "VLESS-WebSocket-tls" "Manage VLESS-WebSocket-tls" \
        "VLESS-gRPC-tls" "Manage VLESS-gRPC-tls" \
        "ShadowTLS" "Manage ShadowTLS" \
        "Hysteria2" "Manage Hysteria2" \
        "Reality" "Manage Reality" \
        "Tuic-V5" "Manage Tuic-V5" \
        "Naive" "Manage Naive" \
        "Warp" "Manage Warp" \
        "" "" \
        "Exit" "Exit the script" 3>&1 1>&2 2>&3)
    case $user_choice in
    "Optimize")
        clear
        optimize_server
        ;;
    "Update")
        clear
        update_sing-box_core
        ;;
    "Hysteria2")
        while true; do
            user_choice=$(whiptail --clear --title "Hysteria2 Menu" --menu "Please select an option:" 25 50 15 \
                "1" "Install" \
                "2" "Modify Config" \
                "3" "Add a new user" \
                "4" "Remove an existing user" \
                "5" "Show User Configs" \
                "6" "Enable/Disable WARP" \
                "7" "Uninstall" \
                "0" "Back to Main Menu" 3>&1 1>&2 2>&3)
            case $user_choice in
            "1")
                clear
                hysteria_check="/etc/hysteria2/server.json"

                if [ -e "$hysteria_check" ]; then
                    whiptail --msgbox "Hysteria2 is Already installed " 10 30
                    clear
                else
                    while true; do
                        user_choice=$(whiptail --clear --title "Hysteria2 Installation Menu" --menu "Please select an option:" 25 50 15 \
                            "1" "With OBFS" \
                            "2" "Without OBFS" \
                            "0" "Back" 3>&1 1>&2 2>&3)
                        case $user_choice in
                        "1")
                            clear
                            install_hysteria obfs
                            ;;
                        "2")
                            clear
                            install_hysteria native
                            ;;
                        "0")
                            break
                            ;;
                        *)
                            whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                            ;;
                        esac
                        break
                    done
                fi
                ;;
            "2")
                clear
                hysteria_check="/etc/hysteria2/server.json"

                if [ -e "$hysteria_check" ]; then
                    while true; do
                        user_choice=$(whiptail --clear --title "Hysteria2 Modification Menu" --menu "Please select an option:" 25 50 15 \
                            "1" "With OBFS" \
                            "2" "Without OBFS" 3>&1 1>&2 2>&3)
                        case $user_choice in
                        "1")
                            clear
                            modify_hysteria_config obfs
                            ;;
                        "2")
                            clear
                            modify_hysteria_config native
                            ;;
                        *)
                            whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                            ;;
                        esac
                        break
                    done
                else
                    whiptail --msgbox "Hysteria2 is not installed yet." 10 30
                    clear
                fi
                ;;
            "3")
                clear
                add_hysteria_user
                ;;
            "4")
                clear
                remove_hysteria_user
                ;;
            "5")
                clear
                show_hysteria_config
                ;;
            "6")
                clear
                toggle_warp_hysteria
                ;;
            "7")
                clear
                uninstall_hysteria
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "Tuic-V5")
        while true; do
            user_choice=$(whiptail --clear --title "Tuic-V5 Menu" --menu "Please select an option:" 25 50 15 \
                "1" "Install" \
                "2" "Modify Config" \
                "3" "Add a new user" \
                "4" "Remove an existing user" \
                "5" "Show User Configs" \
                "6" "Enable/Disable WARP" \
                "7" "Uninstall" \
                "0" "Back to Main Menu" 3>&1 1>&2 2>&3)
            case $user_choice in
            "1")
                clear
                install_tuic
                ;;
            "2")
                clear
                modify_tuic_config
                ;;
            "3")
                clear
                add_tuic_user
                ;;
            "4")
                clear
                remove_tuic_user
                ;;
            "5")
                clear
                show_tuic_config
                ;;
            "6")
                clear
                toggle_warp_tuic
                ;;
            "7")
                clear
                uninstall_tuic
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "Reality")
        while true; do
            user_choice=$(whiptail --clear --title "Reality Menu" --menu "Please select an option:" 25 50 15 \
                "1" "Install" \
                "2" "Modify Config" \
                "3" "Regenerate Keys" \
                "4" "Add a new user" \
                "5" "Remove an existing user" \
                "6" "Show User Configs" \
                "7" "Enable/Disable WARP" \
                "8" "Uninstall" \
                "0" "Back to Main Menu" 3>&1 1>&2 2>&3)
            case $user_choice in
            "1")
                clear
                reality_check="/etc/reality/config.json"

                if [ -e "$reality_check" ]; then
                    whiptail --msgbox "Reality is Already installed " 10 30
                    clear
                else
                    while true; do
                        user_choice=$(whiptail --clear --title "Reality Installation Menu" --menu "Please select Transport Type:" 25 50 15 \
                            "1" "gRPC" \
                            "2" "TCP" \
                            "0" "Back" 3>&1 1>&2 2>&3)
                        case $user_choice in
                        "1")
                            clear
                            install_reality grpc
                            ;;
                        "2")
                            clear
                            install_reality tcp
                            ;;
                        "0")
                            break
                            ;;
                        *)
                            whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                            ;;
                        esac
                        break
                    done
                fi
                ;;
            "2")
                clear
                reality_check="/etc/reality/config.json"

                if [ -e "$reality_check" ]; then
                    while true; do
                        user_choice=$(whiptail --clear --title "Reality Modification Menu" --menu "Please select Transport Type:" 25 50 15 \
                            "1" "gRPC" \
                            "2" "TCP" 3>&1 1>&2 2>&3)
                        case $user_choice in
                        "1")
                            clear
                            modify_reality_config grpc
                            ;;
                        "2")
                            clear
                            modify_reality_config tcp
                            ;;
                        *)
                            whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                            ;;
                        esac
                        break
                    done
                else
                    whiptail --msgbox "Reality is not installed yet." 10 30
                    clear
                fi
                ;;
            "3")
                clear
                regenerate_keys
                ;;
            "4")
                clear
                add_reality_user
                ;;
            "5")
                clear
                remove_reality_user
                ;;
            "6")
                clear
                show_reality_config
                ;;
            "7")
                clear
                toggle_warp_reality
                ;;
            "8")
                clear
                uninstall_reality
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "ShadowTLS")
        while true; do
            user_choice=$(whiptail --clear --title "ShadowTLS Menu" --menu "Please select an option:" 25 50 15 \
                "1" "Install " \
                "2" "Modify Config" \
                "3" "Add a new user" \
                "4" "Remove an existing user" \
                "5" "Show User Configs" \
                "6" "Enable/Disable WARP" \
                "7" "Uninstall" \
                "0" "Back to Main Menu" 3>&1 1>&2 2>&3)
            case $user_choice in
            "1")
                clear
                install_shadowtls
                ;;
            "2")
                clear
                modify_shadowtls_config
                ;;
            "3")
                clear
                add_shadowtls_user
                ;;
            "4")
                clear
                remove_shadowtls_user
                ;;
            "5")
                clear
                show_shadowtls_config
                ;;
            "6")
                clear
                toggle_warp_shadowtls
                ;;
            "7")
                clear
                uninstall_shadowtls
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "VLESS-WebSocket-tls")
        while true; do
            user_choice=$(whiptail --clear --title "VLESS-WebSocket-tls Menu" --menu "Please select an option:" 25 50 15 \
                "1" "Install" \
                "2" "Modify Config" \
                "3" "Add a new user" \
                "4" "Remove an existing user" \
                "5" "Show User Configs" \
                "6" "Enable/Disable WARP" \
                "7" "Uninstall" \
                "0" "Back to Main Menu" 3>&1 1>&2 2>&3)
            case $user_choice in
            "1")
                clear
                install_ws
                ;;
            "2")
                clear
                modify_ws_config
                ;;
            "3")
                clear
                add_ws_user
                ;;
            "4")
                clear
                remove_ws_user
                ;;
            "5")
                clear
                show_ws_config
                ;;
            "6")
                clear
                toggle_warp_ws
                ;;
            "7")
                clear
                uninstall_ws
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "VLESS-gRPC-tls")
        while true; do
            user_choice=$(whiptail --clear --title "VLESS-gRPC-tls Menu" --menu "Please select an option:" 25 50 15 \
                "1" "Install" \
                "2" "Modify Config" \
                "3" "Add a new user" \
                "4" "Remove an existing user" \
                "5" "Show User Configs" \
                "6" "Enable/Disable WARP" \
                "7" "Uninstall" \
                "0" "Back to Main Menu" 3>&1 1>&2 2>&3)
            case $user_choice in
            "1")
                clear
                install_grpc
                ;;
            "2")
                clear
                modify_grpc_config
                ;;
            "3")
                clear
                add_grpc_user
                ;;
            "4")
                clear
                remove_grpc_user
                ;;
            "5")
                clear
                show_grpc_config
                ;;
            "6")
                clear
                toggle_warp_grpc
                ;;
            "7")
                clear
                uninstall_grpc
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;        
    "Naive")
        while true; do
            user_choice=$(whiptail --clear --title "Naive Menu" --menu "Please select an option:" 25 50 15 \
                "1" "Install" \
                "2" "Modify Config" \
                "3" "Add a new user" \
                "4" "Remove an existing user" \
                "5" "Show User Configs" \
                "6" "Enable/Disable WARP" \
                "7" "Uninstall" \
                "0" "Back to Main Menu" 3>&1 1>&2 2>&3)
            case $user_choice in
            "1")
                clear
                install_naive
                ;;
            "2")
                clear
                modify_naive_config
                ;;
            "3")
                clear
                add_naive_user
                ;;
            "4")
                clear
                remove_naive_user
                ;;
            "5")
                clear
                show_naive_config
                ;;
            "6")
                clear
                toggle_warp_naive
                ;;
            "7")
                clear
                uninstall_naive
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "Warp")
        while true; do
            user_choice=$(whiptail --clear --title "Warp Menu" --menu "Please select an option:" 25 50 15 \
                "1" "Generate WARP+ Key" \
                "2" "Generate WARP+ Wireguard Config" \
                "3" "Show Config" \
                "4" "Uninstall" \
                "0" "Back to Main Menu" 3>&1 1>&2 2>&3)
            case $user_choice in
            "1")
                clear
                warp_key_gen
                ;;
            "2")
                clear
                install_warp
                ;;
            "3")
                clear
                show_warp_config
                ;;
            "4")
                clear
                uninstall_warp
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "Exit")
        clear
        echo "Exiting."
        exit 0
        ;;
    *)
        whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
        ;;
    esac
done
