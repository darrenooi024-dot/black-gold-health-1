package com.blackgold.health

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val Gold = Color(0xFFD6B15E)
private val Black = Color(0xFF090909)
private val Panel = Color(0xFF191919)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { BlackGoldApp() }
    }
}

@Composable
fun BlackGoldApp() {
    var selected by remember { mutableStateOf("总览") }
    var profile by remember { mutableStateOf("我") }
    MaterialTheme(colorScheme = darkColorScheme(primary = Gold, background = Black, surface = Panel)) {
        Scaffold(containerColor = Black, bottomBar = {
            NavigationBar(containerColor = Panel, contentColor = Gold) {
                listOf("总览", "体重", "饮食", "运动", "我的").forEach { item ->
                    NavigationBarItem(
                        selected = selected == item,
                        onClick = { selected = item },
                        icon = { Text(when (item) { "总览" -> "⌂"; "体重" -> "↗"; "饮食" -> "◉"; "运动" -> "✦"; else -> "●" }, fontSize = 20.sp) },
                        label = { Text(item, fontSize = 11.sp) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = Gold, selectedTextColor = Gold,
                            indicatorColor = Color(0xFF342B18),
                            unselectedIconColor = Color.LightGray,
                            unselectedTextColor = Color.LightGray
                        )
                    )
                }
            }
        }) { pad ->
            LazyColumn(
                modifier = Modifier.fillMaxSize().background(Black).padding(pad).padding(horizontal = 18.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                item {
                    Spacer(Modifier.height(14.dp))
                    Text("BLACK GOLD", color = Gold, fontSize = 13.sp, fontWeight = FontWeight.Bold, letterSpacing = 3.sp)
                    Text("私人 AI 健康教练", color = Color.White, fontSize = 26.sp, fontWeight = FontWeight.Bold)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.padding(top = 12.dp)) {
                        listOf("我", "宝宝").forEach { person ->
                            FilterChip(selected = profile == person, onClick = { profile = person }, label = { Text(person) },
                                colors = FilterChipDefaults.filterChipColors(selectedContainerColor = Gold, selectedLabelColor = Black, labelColor = Color.White))
                        }
                    }
                }
                item { CardBlock("今日概况", "先记录今天的身体状态", "体重、饮食、饮水和活动都会显示在这里") }
                item { Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) { Metric("体重", "-- kg"); Metric("饮水", "0 ml") } }
                item { Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) { Metric("饮食", "0 kcal"); Metric("步数", "0") } }
                item { CardBlock("快速记录", "体重 · 饮食 · 饮水 · 睡眠", "第一阶段先建立可靠的个人记录。后续接入照片识别、设备同步和云端 AI。") }
                item { CardBlock("运动项目库", "步行、跑步、游泳、力量训练、球类、瑜伽、爬山及自定义运动", "每种运动会逐步加入适合自己的记录字段与消耗估算。") }
                item { CardBlock("AI 教练", "严格监督 · 专业分析 · 主动指导", "AI 云端服务尚未连接；当前为原生界面骨架，不会伪造分析结果。") }
                item { Text("版本 1.0.0 · 原生 Android 项目起始版", color = Color.Gray, fontSize = 11.sp, modifier = Modifier.padding(vertical = 12.dp)) }
            }
        }
    }
}

@Composable
fun CardBlock(title: String, headline: String, detail: String) {
    Card(colors = CardDefaults.cardColors(containerColor = Panel), shape = RoundedCornerShape(18.dp), modifier = Modifier.fillMaxWidth()) {
        Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(title, color = Gold, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
            Text(headline, color = Color.White, fontSize = 17.sp, fontWeight = FontWeight.Bold)
            Text(detail, color = Color.LightGray, fontSize = 13.sp, lineHeight = 19.sp)
        }
    }
}

@Composable
fun RowScope.Metric(label: String, value: String) {
    Card(colors = CardDefaults.cardColors(containerColor = Panel), shape = RoundedCornerShape(16.dp), modifier = Modifier.weight(1f)) {
        Column(Modifier.padding(15.dp)) {
            Text(label, color = Color.LightGray, fontSize = 12.sp)
            Spacer(Modifier.height(7.dp))
            Text(value, color = Gold, fontSize = 22.sp, fontWeight = FontWeight.Bold)
        }
    }
}